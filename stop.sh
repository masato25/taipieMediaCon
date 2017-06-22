ps auxww|grep iex|awk -F' ' '{system("kill -9 " $2)}'
