'''
Log format used here -
2021/05/27 05:59:58.106|Info|HttpPostCall    | Time taken by devices : 00:00:01.1247312
2021/05/27 05:59:58.121|Info|HttpPostCall    | Time taken by devices : 00:00:01.0242185
2021/05/27 05:59:58.121|Info|HttpPostCall    | Time taken by devices : 00:00:00.9155217
'''
import csv
def decode_nginx_log(_nginx_fd)):
    with open(_nginx_fd, "r") as stl:
        secs = []
        alldata = csv.reader(stl)
        for row in alldata:
            Splidata = row[0].split('|')
            timetaken = Splidata[-1].split(' : ')[-1]
            es_fields_keys = ('timetaken')
            es_fields_vals = (timetaken)
            idx = Splidata[0]
            es_nginx_d = dict(zip(es_fields_keys, es_fields_vals))
            yield idx, es_nginx_d

data = decode_nginx_log("ServiceTimeLog.log")