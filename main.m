clc
clearvars
AllClosed = true;
databaseName = '20120206_Pullman - Edited';
conn_warehouse = database('Warehouse','','');
conn_model = database(databaseName,'','');
exclude_nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'TUR115',AllClosed);
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'SPU125',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'SPU122',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'SPU124',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'TUR117',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'TUR111',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];
nodes = Convert_synergi2glm(conn_model, conn_warehouse, 'TVW131',AllClosed, exclude_nodes);
exclude_nodes = [exclude_nodes; nodes];

close(conn_warehouse)
close(conn_model)