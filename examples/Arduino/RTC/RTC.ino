#include <Arduino.h>
#include <STM32RTC.h>

//Светодиод на D13
#define LED 13
//rtc объект
STM32RTC& rtc = STM32RTC::getInstance();

void setup() {
//Подключение пользовательской кнопки для быстрой перезагрузки и входа в режим загрузчика (DFU)
  //Включение тактирования порта GPIOH
  __HAL_RCC_GPIOH_CLK_ENABLE();
  //подключение прерывания для вывода PH3, для активации RESET по нажатию кнопки
  stm32_interrupt_enable(GPIOH, LL_GPIO_PIN_3, NVIC_SystemReset, GPIO_MODE_IT_RISING);

// Запуск USB Device в режиме CDC (виртуальный COM-порт)
  SerialUSB.begin();

  pinMode(LED, OUTPUT);

  rtc.begin(); // Инициализация RTC
  // Установка времени и даты
  rtc.setHours(12);
  rtc.setMinutes(15);
  rtc.setSeconds(0);
  rtc.setWeekDay(1);
  rtc.setDay(15);
  rtc.setMonth(11);
  rtc.setYear(24);
}

bool led = false;
int i = 0;
void loop() {

  Serial.printf("%02d/%02d/%02d ", rtc.getDay(), rtc.getMonth(), rtc.getYear());
  Serial.printf("%02d:%02d:%02d.%03d\n", rtc.getHours(), rtc.getMinutes(), rtc.getSeconds(), rtc.getSubSeconds());
  delay(250);
}