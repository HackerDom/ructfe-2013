help:
	echo Targets: main-db test-db clean

main-db:
	psql -f game-databases-create.sql
	./run.sh ructfe ructfe tables-create.sql
	./run.sh ructfe ructfe ructfe2013-services.sql
	./run.sh ructfe ructfe game-teams-add.sql
	./change-owner.sh ructfe ructfe

test-db:
	psql -f test-databases-create.sql
	./run.sh testuser ructfetest tables-create.sql
	./run.sh testuser ructfetest ructfe2013-services.sql
	./run.sh testuser ructfetest test-teams-add.sql
	./change-owner.sh ructfetest testuser

clean:
	./run.sh tables-clear.sql
