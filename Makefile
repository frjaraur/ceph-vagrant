update:
	@git pull
destroy:
	@vagrant destroy -f || true
	@rm -rf tmp_deploying_stage
	@rm -rf tmp_disks

create:
	@vagrant up -d

recreate:
	@make destroy
	@make create

stop:
	@VBoxManage controlvm ceph-osd3 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm ceph-osd2 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm ceph-osd1 acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm ceph-mon acpipowerbutton 2>/dev/null || true
	@VBoxManage controlvm ceph-adm acpipowerbutton 2>/dev/null || true

start:
	@VBoxManage startvm ceph-adm --type headless 2>/dev/null || true
	@sleep 10
	@VBoxManage startvm ceph-mon --type headless 2>/dev/null || true
	@sleep 10
	@VBoxManage startvm ceph-osd1 --type headless 2>/dev/null || true
	@VBoxManage startvm ceph-osd2 --type headless 2>/dev/null || true
	@VBoxManage startvm ceph-osd3 --type headless 2>/dev/null || true

status:
	@VBoxManage list runningvms
