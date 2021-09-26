
create table di_projects
(
    proj_id          int unsigned auto_increment 
        primary key,
    proj_name        varchar(100) default ''                not null,
    proj_local_path  varchar(100) default ''                not null,
    proj_repo_path   varchar(100) default ''                not null,
    proj_ts_created  datetime     default CURRENT_TIMESTAMP not null,
    proj_ts_modified timestamp    default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint di_projects_proj_name_uindex
        unique (proj_name)
)
    charset = utf8;

INSERT INTO di_projects (proj_id, proj_name, proj_local_path, proj_repo_path) VALUES (1, 'project_1', '/test/example/repositories/project_1/', '');
INSERT INTO di_projects (proj_id, proj_name, proj_local_path, proj_repo_path) VALUES (2, 'project_2', '/test/example/repositories/project_2/', '');


create table di_libraries
(
    lib_id           int unsigned auto_increment
        primary key,
    lib_name         varchar(100) default ''                not null,
    lib_developed_by varchar(10)  default ''                not null,
    lib_local_path   varchar(100) default ''                not null,
    lib_repo_path    varchar(100) default ''                not null,
    lib_ts_created   datetime     default CURRENT_TIMESTAMP not null,
    lib_ts_modified  timestamp    default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint di_libraries_lib_name_uindex
        unique (lib_name)
)
    charset = utf8;

INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (1, 'library_1', 'in-house', '/test/example/repositories/library_1/', 'git://github.com/ddeaustria/exercise_1/library_1.git');
INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (2, 'library_2', 'in-house', '/test/example/repositories/library_2/', 'git://github.com/ddeaustria/exercise_1/library_2.git');
INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (3, 'library_3', '3rd-party', '/test/example/repositories/library_3/', 'git://github.com/others/exercise_1/library_3.git');
INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (4, 'library_4', 'in-house', '/test/example/repositories/library_4/', 'git://github.com/ddeaustria/exercise_1/library_4.git');
INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (5, 'library_5', '3rd-party', '/test/example/repositories/library_5/', 'git://github.com/others/exercise_1/library_5.git');
INSERT INTO di_libraries (lib_id, lib_name, lib_developed_by, lib_local_path, lib_repo_path) VALUES (6, 'library_6', '3rd-party', '/test/example/repositories/library_6/', 'git://github.com/others/exercise_1/library_6.git');


create table di_lib_dependencies
(
    libd_id                int unsigned auto_increment primary key,
    libd_base_lib_id       int unsigned not null,
    libd_depends_on_lib_id int unsigned not null,
    constraint di_lib_dependencies_uindex
        unique (libd_base_lib_id, libd_depends_on_lib_id)
);

create index di_lib_dependencies_di_libraries_lib_id_fk_2
    on di_lib_dependencies (libd_depends_on_lib_id);

INSERT INTO di_lib_dependencies (libd_id, libd_base_lib_id, libd_depends_on_lib_id) VALUES (1, 2, 4);
INSERT INTO di_lib_dependencies (libd_id, libd_base_lib_id, libd_depends_on_lib_id) VALUES (2, 2, 5);


create table di_projects_libs_included
(
    pli_id          int unsigned auto_increment
        primary key,
    pli_proj_id     int unsigned                        not null,
    pli_lib_id      int unsigned                        not null,
    pli_ts_modified timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint di_projects_libs_included_uindex
        unique (pli_proj_id, pli_lib_id),
    constraint di_projects_libs_included_di_libraries_lib_id_fk
        foreign key (pli_lib_id) references di_libraries (lib_id),
    constraint di_projects_libs_included_di_projects_proj_id_fk
        foreign key (pli_proj_id) references di_projects (proj_id)
            on delete cascade
);

INSERT INTO di_projects_libs_included (pli_id, pli_proj_id, pli_lib_id) VALUES (1, 1, 1);
INSERT INTO di_projects_libs_included (pli_id, pli_proj_id, pli_lib_id) VALUES (2, 1, 2);
INSERT INTO di_projects_libs_included (pli_id, pli_proj_id, pli_lib_id) VALUES (3, 1, 3);
INSERT INTO di_projects_libs_included (pli_id, pli_proj_id, pli_lib_id) VALUES (4, 2, 2);
INSERT INTO di_projects_libs_included (pli_id, pli_proj_id, pli_lib_id) VALUES (5, 2, 6);


create table ft_lib_changes
(
    libch_id          bigint unsigned auto_increment
        primary key,
    libch_date        datetime                            not null,
    libch_lib_id      int unsigned                        not null,
    libch_ts_created  datetime  default CURRENT_TIMESTAMP not null,
    libch_ts_modified timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP
);


INSERT INTO ft_lib_changes (libch_date, libch_lib_id) VALUES ('2021-09-20 23:30', 1);
INSERT INTO ft_lib_changes (libch_date, libch_lib_id) VALUES ('2021-09-21 14:30', 2);
INSERT INTO ft_lib_changes (libch_date, libch_lib_id) VALUES ('2021-09-23 16:00', 1);
INSERT INTO ft_lib_changes (libch_date, libch_lib_id) VALUES ('2021-09-26 17:00', 1);
