load('api_gpio.js');
load('api_sys.js');
load('api_arduino_ssd1306.js');
load('api_timer.js');
load('api_dht.js');
load('api_log.js');

let _newLedPlayback = ffi('void* newLedPlayback(int, int, char*)');
let _playImage = ffi('void playImage(void*, char*)');
function LedPlayback(pin, numLeds, imageDir) {
    let lp = Object.create({});
    lp._c = _newLedPlayback(pin, numLeds, imageDir);
    lp.playImage = function(filename) { _playImage(lp._c, filename); };
    return lp;
}

let NimMain = ffi('void NimMain()');
NimMain()

// pin5 solder is bad
GPIO.set_mode(25, GPIO.MODE_OUTPUT);

// from conf0.js, i2c sda is on 4; scl is on 15
// display reset is 16

GPIO.set_mode(36,  GPIO.MODE_INPUT);  //sw
GPIO.set_mode(37,  GPIO.MODE_INPUT);  //d
GPIO.set_mode(38,  GPIO.MODE_INPUT);  //clk

function welcomeBlink() {
    for( let i=0; i<3; i++) {
        GPIO.write(25, 1); Sys.usleep(100000);
        GPIO.write(25, 0); Sys.usleep(100000);
    }
}

let lp = LedPlayback(/*pin=*/22, /*numPixels=*/8, "");
lp.playImage('img_spin.bin');
Log.info('img done');

welcomeBlink();

let disp = Adafruit_SSD1306.create_i2c(/*rst*/16, Adafruit_SSD1306.RES_128_64);
disp.begin(Adafruit_SSD1306.SWITCHCAPVCC, 0x3C, true /* reset */);
disp.display();

disp.setTextColor(Adafruit_SSD1306.WHITE);
disp.setTextSize(2);

let o = {disp: disp, temp: 0, pos: 0, step: 0};

GPIO.set_int_handler(38, GPIO.INT_EDGE_ANY, function(pin) {
    o.pos += (GPIO.read(37) === GPIO.read(38)) ? 1 : -1;
leds(o.pos% 8);
}, null);
GPIO.enable_int(38);

o.dht = DHT.create(23, DHT.AM2302);

Timer.set(2100, true, function(o) {
    o.temp = o.dht.getTemp();
}, o);

Timer.set(200, true, function(o) {
    let disp = o.disp;
    disp.clearDisplay();
    disp.setCursor(0, 0);
    let tempf = o.temp * 9 / 5 + 32;
    disp.write(JSON.stringify({'t': Timer.now(),
                               'temp': Math.round(tempf * 10) / 10,
                               'sw': !GPIO.read(36),
                               'pos': o.pos
                              }));
    disp.display();
}, o);

Log.info("disp looping");

GPIO.write(25, 1); Sys.usleep(400000);
GPIO.write(25, 0);
