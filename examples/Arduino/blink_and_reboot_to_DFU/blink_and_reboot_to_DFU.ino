//Светодиод на D13
#define LED 13
 
void setup() {
  //Подключение пользовательской кнопки для быстрой перезагрузки и входа в режим загрузчика (DFU)
  //Включение тактирования порта GPIOH
  __HAL_RCC_GPIOH_CLK_ENABLE();
  //переключение вывода PH3 в режим входа
  LL_GPIO_SetPinMode(GPIOH, LL_GPIO_PIN_3, LL_GPIO_MODE_INPUT);
 
  pinMode(LED, OUTPUT);
  // Запуск USB Device в режиме CDC (виртуальный COM-порт)
  // Для успешной сборки подключить поддержку USB CDC в Arduino IDE
  SerialUSB.begin();
}
 
bool led = false;
int i = 0;
void loop() {
  // проверка нажата ли кнопка
  if (LL_GPIO_IsInputPinSet(GPIOH, LL_GPIO_PIN_3)) {
    //перезагрузка микроконтроллера
    NVIC_SystemReset();
  }
 
  if (led) {
    led = false;
    digitalWrite(LED, HIGH);
  } else {
    led = true;
    digitalWrite(LED, LOW);
  }
  delay(250);
  i++;
  Serial.print(i);
}