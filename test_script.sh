sudo systemctl stop chronyd
future=2020-07-05
sudo date --set 
# get list of nodes
# Do for i=2=6
for i in {1..5}
do
  ip=oc get nodes -o wide | awk '{if(NR==2) print }'
  ssh-keyscan -H  >> ~/.ssh/known_hosts
  ssh core@
  ssh -t core@ "sudo systemctl stop chronyd && sudo systemctl stop crio && sudo systemctl stop kubelet && sudo date --set "
  ssh -t core@ "sudo systemctl start crio && sudo systemctl start kubelet"
done
oc get csr -o name | xargs oc adm certificate approve
