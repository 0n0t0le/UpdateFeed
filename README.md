### Подготовка к настройке:

Необходимо, чтобы cli_wallet был запущен. Это можно сделать командой

`screen -dmS cliwallet ./cli_wallet --server-rpc-endpoint=ws://127.0.0.1:8090 --rpc-http-endpoint=127.0.0.1:8091 --rpc-http-allowip 127.0.0.1 -d`
где

- ws://127.0.0.1:8090 - rpc-endpoint вашей ноды
- 127.0.0.1:8091 - адрес на котором будет слушать команды запущенный клиент

Также необходимо установить следующие пакеты

- jq - утилита для работы с JSON
- bc - калькулятор
- curl - HTTP клиент (скорее всего у Вас уже установлен)

`sudo apt-get install jq bc curl`

Для самого скрипта необходимо добавить в .bash_profile некоторые переменные, индивидуальные для каждого делегата

`echo "export GOLOS_WALLET=http://127.0.0.1:8091" » $HOME/.bash_profile`
`echo "export GOLOS_PASSWORD=YOURstrongPSSWRD" » $HOME/.bash_profile`
`echo "export GOLOS_WITNESS=on0tole" » $HOME/.bash_profile`

где

- WALLET - rpc адрес cli_wallet
- WITNESS - имя делегата, от имени которого будет публиковаться фид
- PASSWORD - пароль для разблокировки cli_wallet
