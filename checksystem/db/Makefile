help:
	echo Targets: create-test drop-test create-game drop-game

create-game:
	psql -af databases-create.sql postgres
	psql -f tables-create.sql ructfe11
	psql -f tables-create.sql ructfe12
	psql -f tables-create.sql ructfe13
	psql -f tables-create.sql ructfe21
	psql -f tables-create.sql ructfe22
	psql -f data.services.sql ructfe11
	psql -f data.services.sql ructfe12
	psql -f data.services.sql ructfe13
	psql -f data.services.sql ructfe21
	psql -f data.services.sql ructfe22
	./change-owner.sh ructfe11 ructfe
	./change-owner.sh ructfe12 ructfe
	./change-owner.sh ructfe13 ructfe
	./change-owner.sh ructfe21 ructfe
	./change-owner.sh ructfe22 ructfe

drop-game:
	psql -af game-databases-drop.sql postgres

create-test:
	psql -af test-databases-create.sql postgres
	psql -f tables-create.sql ructfetest
	./change-owner.sh ructfetest testuser
	psql -f test-data-add.sql ructfetest

drop-test:
	psql -af test-databases-drop.sql postgres
