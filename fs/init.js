load('api_gpio.js');
load('api_sys.js');
load('api_arduino_ssd1306.js');
load('api_timer.js');


GPIO.set_mode(25, GPIO.MODE_OUTPUT);

for( let i=0; i<3; i++) {
    GPIO.write(25, 1); Sys.usleep(100000);
    GPIO.write(25, 0); Sys.usleep(100000);
}

let disp = Adafruit_SSD1306.create_i2c(16, Adafruit_SSD1306.RES_128_64);
disp.begin(Adafruit_SSD1306.SWITCHCAPVCC, 0x3C, true /* reset */);
disp.display();

disp.setTextColor(Adafruit_SSD1306.WHITE);
disp.setTextSize(1);

Timer.set(1, true, function() {
    disp.clearDisplay();
    disp.setCursor(0, 0);
    disp.write('hello t=' + JSON.stringify(Timer.now()));
    disp.display();
}, null);

GPIO.write(25, 1); Sys.usleep(400000);
GPIO.write(25, 0);
