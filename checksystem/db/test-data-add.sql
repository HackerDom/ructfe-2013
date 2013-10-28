-- Test team for RuCTFe-2012

--INSERT INTO teams VALUES ( 1, 'Team 3',  '10.24.2.3/32',  '10.24.2.3',  true );
--INSERT INTO teams VALUES ( 2, 'Team 11', '10.24.2.11/32', '10.24.2.11', true );
INSERT INTO teams VALUES ( 211, 'Team 211', '10.23.201.211/32', '10.23.201.211', true );
INSERT INTO teams VALUES ( 212, 'Team 212', '10.23.201.212/32', '10.23.201.212', true );
INSERT INTO teams VALUES ( 213, 'Team 213', '10.23.201.213/32', '10.23.201.213', true );
INSERT INTO teams VALUES ( 214, 'Team 214', '10.23.201.214/32', '10.23.201.214', true );
INSERT INTO teams VALUES ( 215, 'Team 215', '10.23.201.215/32', '10.23.201.215', true );

INSERT INTO services VALUES ( 1, 'buster',        './Buster/buster.checker.sh'                );
INSERT INTO services VALUES ( 2, 'booking',       './booking/booking.checker.pl'              );
INSERT INTO services VALUES ( 3, 'flightprocess', './flightprocess/flightprocess.checker.pl'  );
INSERT INTO services VALUES ( 4, 'flybook',       './FlyBook/FlyBook.check.py'                );
INSERT INTO services VALUES ( 5, 'gds',           './gds/checker.py'                          );
INSERT INTO services VALUES ( 6, 'geotracker',    './geotracker/geotracker.checker.pl'        );
INSERT INTO services VALUES ( 7, 'mch',           './mch/mch.checker.pl'                      );
INSERT INTO services VALUES ( 8, 'lust',          './lust/lust.checker.sh'                    );

