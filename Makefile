# Usage: make up LAB=01   (any unique prefix of a folder in labs/ works)
LAB ?= 01
DIR  := $(firstword $(wildcard labs/$(LAB)*))
TOPO := $(DIR)/topology.clab.yml
NUM  := $(shell echo $(notdir $(DIR)) | cut -c1-2)

.PHONY: help list up down reset check solve shell

help:
	@echo "make list                 show the labs"
	@echo "make up    LAB=01         start a lab"
	@echo "make check LAB=01         grade your work"
	@echo "make solve LAB=01         apply the reference solution"
	@echo "make reset LAB=01         destroy and start fresh"
	@echo "make down  LAB=01         stop a lab"
	@echo "make shell LAB=01 NODE=h1 open a shell on a node"

list:
	@ls -1 labs

up:
	@test -n "$(DIR)" || (echo "No lab matches '$(LAB)'"; exit 1)
	sudo containerlab deploy -t $(TOPO) --reconfigure

down:
	sudo containerlab destroy -t $(TOPO) --cleanup

reset: down up

check:
	@bash $(DIR)/check.sh

solve:
	@bash $(DIR)/solution.sh

shell:
	@docker exec -it clab-lab$(NUM)-$(NODE) sh -c 'command -v vtysh >/dev/null && echo "(router: type vtysh for the FRR CLI)"; command -v bash >/dev/null && exec bash; exec sh' || true
