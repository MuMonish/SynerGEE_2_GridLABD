clc
clearvars
AllClosed = false;
databaseName = '20120206_Pullman - Edited';
conn_warehouse = database('Warehouse','','');
conn_model = database(databaseName,'','');
Convert_synergi2glm(conn_model, conn_warehouse, 'SPU122',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'SPU125',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'TUR111',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'TUR115',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'TUR117',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'TVW131',AllClosed)
Convert_synergi2glm(conn_model, conn_warehouse, 'SPU124',AllClosed)

close(conn_warehouse)
close(conn_model)