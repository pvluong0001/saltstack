# Cài đặt docker-compose(require docker and docker-compose)
+ B1: cd /path/to/project && **docker-compose build**: Build docker
+ B2: **docker-compose up --scale minion=<number>**: Start docker container với số lượng minion = **number**(VD: ... --scale minion=5)
+ B3: connect vào master container = câu lệnh **docker exec -it master bash**(có thể bị trùng name) hoặc sử dụng câu lệnh **docker ps**
    ```bash
    F:\nodejs\product
    λ docker ps
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
    239c6626e659        salt_minion         "salt-minion -l debug"   8 hours ago         Up 2 seconds                            salt_minion_2
    c3955501258f        salt_minion         "salt-minion -l debug"   8 hours ago         Up 2 seconds                            salt_minion_1
    4de21f52be2d        salt_master         "/usr/sbin/init"         8 hours ago         Up 2 seconds                            master
    ```
    + sử dụng **docker exec -it 4de21f52be2d bash** để truy cập vào master container.
+ B4: Sau khi truy cập vào master container sử dụng câu lệnh **service salt-master restart** để start salt-master service

# Các câu lệnh thường sử dụng trong:
+ **service salt-master start/restart/stop/status**: Start/stop salt-master service
+ **salt "minion_name" test.ping**: Kiểm tra trạng thái của các minion(sử dụng * nếu muốn xem tất cả)
```bash
[root@4de21f52be2d ~]# salt '*' test.ping
239c6626e659:
    True
c3955501258f:
    True
```
+ **salt-key -L**: Kiểm tra tất cả các key được accept/denied/unaccept/reject vào master.
```bash
[root@4de21f52be2d ~]# salt-key -L
Accepted Keys:
239c6626e659
c3955501258f
Denied Keys:
Unaccepted Keys:
Rejected Keys:
```
+ **salt "minion_name" cmd.run "command_will_run_in_minion"**: Thực hiện chạy câu lệnh phía minion.
```bash
[root@4de21f52be2d ~]# salt '*' cmd.run "ls"
c3955501258f:
    master.txt
    test
239c6626e659:
    master.txt
    test
```
+ **salt-cp "minion_name" /path/in/master/file /path/in/minion/file**: Thực hiện copy file từ master xuống minion
```bash
[root@4de21f52be2d ~]# salt-cp '*' master.txt ~/master2.txt
239c6626e659:
    ----------
    /root/master2.txt:
        True
c3955501258f:
    ----------
    /root/master2.txt:
        True
```
+ **salt-run state.event pretty=True**: Listen event trong event bus
    + Advanced: Fire event từ minion -> master
    + Minion: 
        + **salt-call event.fire '{"data": "message to be sent in the event"}' 'tag'**
        + **salt-call event.send 'luonglit/tag/testevent' '{success: True, message: "It works!"}'**
    + Master:
        + Cấu hình python để lắng nghe sự kiện
        + ```
            import fnmatch
            
            import salt.config
            import salt.utils.event
            import json
            
            opts = salt.config.client_config('/etc/salt/master')
            
            sevent = salt.utils.event.get_event(
                    'master',
                    sock_dir=opts['sock_dir'],
                    transport=opts['transport'],
                    opts=opts)
            
            while True:
                ret = sevent.get_event(full=True)
                if ret is None:
                    continue
            
                # su kien custom
                if fnmatch.fnmatch(ret['tag'], 'luonglit/tag/*'):
                    # call to server to save data or something el
                    outfile = open('./result.txt', 'a+')
                    outfile.write(json.dumps(ret['data']) + "\n")
                    outfile.close()
            
                # salt/minion/<MID>/start: su kien khi 1 minion ket noi toi master(thuc hien chuc nang on/off tren db)
                if fnmatch.fnmatch(ret['tag'], 'salt/minion/*/start'):
                    outfile = open('./result.txt', 'a+')
                    outfile.write(json.dumps(ret['data']) + "\n")
                    outfile.close()
            ```

# Tài liệu tham khảo:
+ https://docs.saltstack.com/en/latest/topics/tutorials/walkthrough.html ========> basic setup
+ https://docs.saltstack.com/en/latest/ref/cli/salt-key.html ==================> salt-key
+ https://docs.saltstack.com/en/master/topics/event/events.html =============> salt event
