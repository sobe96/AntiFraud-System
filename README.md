# AntiFraud-System

## Terraform
Код для Terraform разделен на модули.
1) iam -- для создания всего, что связано с сервисным аккаунтом
2) network -- для создания сетевой инфраструктуры
3) storage -- создание бакета
4) dataproc -- создание Spark-кластера
5) main -- главный модуль, объединяющий остальные модули. Добавляет гибкость в работу с инфраструктурой

## Точка доступа к бакету
s3://sobe-bucket-b1gjia01631403jq34f0/

## Файлы в HDFS-директории
![hdfs_ls_new.png](terraform%2Fimages%2Fhdfs_ls_new.png)

## Уменьшение костов
1) Первым делом, нужно сделать Data-ноду preemptibe, что я сделал (-3650р)
2) Если скорость передачи данных не очень важна, то можно вместо ssd сделать hdd (-1100р за Data-ноду, -350р за Master-ноду)
3) Гарантированную долю CPU для Master-ноды можно снизить до 50% (-600р)
4) Хранилище (бакет) можно сделать ледяным, но это уже экономия на спичках (-150р с учетом, что операции будут стоить дороже)

### Итого можно уложиться в 5000р/мес. при условии, что мы не учитываем трафик.

![storage_calculator.png](terraform%2Fimages%2Fstorage_calculator.png)
![master_node_calculator.png](terraform%2Fimages%2Fmaster_node_calculator.png)
![data_node_calculator.png](terraform%2Fimages%2Fdata_node_calculator.png)
![final_sum_calculator.png](terraform%2Fimages%2Ffinal_sum_calculator.png)

### Что касается фактической стоимости полной инфраструктуры
Сложновато оценить отношение стоимости HDFS к стоимости S3, потому что кроме дискового пространства мы использовали еще 
и вычислительные ресурсы, но по ощущениям, раз в 10 разница есть точно.

![expense_comparison.png](terraform%2Fimages%2Fexpense_comparison.png)

## Запуск инфраструктуры
Производится из директории main командой
```
terraform init # если ранее не terraform не был проинициализирован
terraform apply -auto-approve
```
## Уничтожение инфраструктуры
Так же, из директории main командой
```
terraform destroy -target=module.network -target=module.dataproc
```
### Почему именно так?
Потому что я сделал модульную структуру terraform-кода. Сделал lifecycle.prevent-destroy для модулей iam и storage,
чтобы можно было оставить только storage, при этом использовать общую сервисную учетку для любых нужд.
Storage нужно оставить работающим, поэтому и iam нельзя уничтожать, чтобы не отлетели acces_key и secret_key.
Если будет необходимо снести storage и iam модули, нужно будет удалить lifecycle-структуру из каждого ресурса этих
модулей, а затем выполнить команды
```
terraform apply # чтобы отключить защиту от уничтожения
terraform destroy -auto-approve
```

### Кластер я удалил, как и сеть, чтобы не тратились лишние деньги, а storage и iam (насколько я понял, он деньги не тратит) - оставил