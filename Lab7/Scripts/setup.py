import os
import subprocess

key_words = ['nfrouter:0', 'nfrouter:1', 'nfrouter:2', 'nfrouter:3']
flag = 0
IP_port_mapping = []
commands = ['sudo /usr/local/netfpga/lib/scripts/cpci_reprogram/cpci_reprogram.pl --all']

HOST = 'control.Lab7-ABD.USCEE533.isi.deterlab.net'


tbreport_path = r'/proj/USCEE533/exp/Lab7-ABD/tbdata' # Location of tbreport.log

os.chdir(tbreport_path)
os.system('ls')


with open('tbreport.log', 'r') as file:

    lines = file.readlines()

    for sentence in lines:

        word = sentence.split()

        if len(word) > 1 and word[1] in key_words:
            
            if word[1] == 'nfrouter:0':
                flag+=1
            
            if flag == 2:
    
                IP_port_mapping.append((word[2],word[3][-1]))
    

for mapping in IP_port_mapping:
    command = 'sudo /sbin/ifconfig nf2c' + mapping[1] + ' ' + mapping[0] + '/24 up'
    commands.append(command)

commands.append('nf_download /usr/local/netfpga/bitfiles/reference_nic.bit')
command = ' && '.join(commands)

ssh = subprocess.Popen(['ssh', "%s" % HOST, command],
                       shell=False,
                       stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE)
result = ssh.stdout.readlines()

for line in result:
    print(line)
    






    
