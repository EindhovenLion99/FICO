-- -----------------------------------------------------
-- Table Deportes
-- -----------------------------------------------------
DROP TABLE IF EXISTS Deportes;

CREATE TABLE IF NOT EXISTS Deportes (
  Nombre_Deporte VARCHAR(20) NOT NULL,
  PRIMARY KEY (Nombre_Deporte));


-- -----------------------------------------------------
-- Table Organizacion
-- -----------------------------------------------------
DROP TABLE IF EXISTS Organizacion;

CREATE TABLE IF NOT EXISTS Organizacion (
  Nombre_Organizacion VARCHAR(50) NOT NULL,
  Region_Organizacion VARCHAR(45) NOT NULL,
  Año_Organizacion INT NOT NULL,
  Nombre_Deporte VARCHAR(20) NOT NULL,
  PRIMARY KEY (Nombre_Organizacion),
    FOREIGN KEY (Nombre_Deporte)
    REFERENCES Deportes (Nombre_Deporte)
    ON DELETE CASCADE
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Competicion
-- -----------------------------------------------------
DROP TABLE IF EXISTS Competicion ;

CREATE TABLE IF NOT EXISTS Competicion (
  Nombre_Competicion VARCHAR(40) NOT NULL,
  Temporada_Competicion VARCHAR(9) NOT NULL,
  Nombre_Organizacion VARCHAR(50) NOT NULL,
  PRIMARY KEY (Nombre_Competicion, Temporada_Competicion),
    FOREIGN KEY (Nombre_Organizacion)
    REFERENCES Organizacion (Nombre_Organizacion)
    ON DELETE CASCADE
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Estadio
-- -----------------------------------------------------
DROP TABLE IF EXISTS Estadio;

CREATE TABLE IF NOT EXISTS Estadio (
  ID_Estadio INT NOT NULL AUTO_INCREMENT,
  Nombre_Estadio VARCHAR(40) NOT NULL,
  Capacidad_Estadio INT NULL,
  PRIMARY KEY (ID_Estadio));


-- -----------------------------------------------------
-- Table Jugador
-- -----------------------------------------------------
DROP TABLE IF EXISTS Jugador;

CREATE TABLE IF NOT EXISTS Jugador (
  ID_Ficha_Jugador INT NOT NULL,
  Nombre_Jugador VARCHAR(50) NOT NULL,
  Posicion_Jugador VARCHAR(45) NOT NULL,
  Salario_Jugador INT NULL,
  Edad_Jugador INT NULL,
  PRIMARY KEY (ID_Ficha_Jugador));


-- -----------------------------------------------------
-- Table Partidos
-- -----------------------------------------------------
DROP TABLE IF EXISTS Partidos ;

CREATE TABLE IF NOT EXISTS Partidos (
  ID_Partido INT NOT NULL,
  Resultado_Partido VARCHAR(5) NOT NULL,
  Fecha_Partido DATE NOT NULL,
  Nombre_Competicion VARCHAR(40) NOT NULL,
  Temporada_Competicion VARCHAR(9) NOT NULL,
  ID_Estadio INT NOT NULL,
  PRIMARY KEY (ID_Partido),
    FOREIGN KEY (Nombre_Competicion , Temporada_Competicion)
    REFERENCES Competicion (Nombre_Competicion , Temporada_Competicion)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_Estadio)
    REFERENCES Estadio (ID_Estadio)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table Club
-- -----------------------------------------------------
DROP TABLE IF EXISTS Club;

CREATE TABLE IF NOT EXISTS Club (
  ID_Club INT NOT NULL,
  Nombre_Club VARCHAR(70) NOT NULL,
  Año_Club VARCHAR(4) NOT NULL,
  Trofeos_Club INT NULL,
  Presupuesto_Club INT NOT NULL,
  ID_Estadio INT NOT NULL,
  PRIMARY KEY (ID_Club),
    FOREIGN KEY (ID_Estadio)
    REFERENCES Estadio (ID_Estadio)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table Personal
-- -----------------------------------------------------
DROP TABLE IF EXISTS Personal;

CREATE TABLE IF NOT EXISTS Personal (
  DNI_Personal VARCHAR(9) NOT NULL,
  Nombre_Personal VARCHAR(50) NOT NULL,
  Puesto_Personal VARCHAR(45) NOT NULL,
  Salario_Personal INT NULL,
  Edad_Personal INT NULL,
  ID_Club INT NULL,
  PRIMARY KEY (DNI_Personal),
    FOREIGN KEY (ID_Club)
    REFERENCES Club (ID_Club)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Entrenador
-- -----------------------------------------------------
DROP TABLE IF EXISTS Entrenador;

CREATE TABLE IF NOT EXISTS Entrenador (
  Titulos_Entrenador INT NOT NULL,
  DNI_Personal VARCHAR(9) NOT NULL,
  PRIMARY KEY (DNI_Personal),
    FOREIGN KEY (DNI_Personal)
    REFERENCES Personal (DNI_Personal)
    ON DELETE CASCADE
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Anfitriona
-- -----------------------------------------------------
DROP TABLE IF EXISTS Anfitriona;

CREATE TABLE IF NOT EXISTS Anfitriona (
  ID_Club INT NOT NULL,
  Nombre_Competicion VARCHAR(40) NOT NULL,
  Temporada_Competicion VARCHAR(9) NOT NULL,
  PRIMARY KEY (ID_Club, Nombre_Competicion, Temporada_Competicion),
    FOREIGN KEY (ID_Club)
    REFERENCES Club (ID_Club)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    FOREIGN KEY (Nombre_Competicion , Temporada_Competicion)
    REFERENCES Competicion (Nombre_Competicion , Temporada_Competicion)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Fichas
-- -----------------------------------------------------
DROP TABLE IF EXISTS Fichas;

CREATE TABLE IF NOT EXISTS Fichas (
  ID_Club INT NOT NULL,
  ID_Ficha_Jugador INT NOT NULL,
  PRIMARY KEY (ID_Club, ID_Ficha_Jugador),
    FOREIGN KEY (ID_Club)
    REFERENCES Club (ID_Club)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_Ficha_Jugador)
    REFERENCES Jugador (ID_Ficha_Jugador)
    ON DELETE CASCADE
    ON UPDATE CASCADE);


-- -----------------------------------------------------
-- Table Participa
-- -----------------------------------------------------
DROP TABLE IF EXISTS Participa;

CREATE TABLE IF NOT EXISTS Participa (
  ID_Club INT NOT NULL,
  ID_Partido INT NOT NULL,
  Rol VARCHAR(9) NOT NULL,
  PRIMARY KEY (ID_Club, ID_Partido),
    FOREIGN KEY (ID_Club)
    REFERENCES Club (ID_Club)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_Partido)
    REFERENCES Partidos (ID_Partido)
    ON DELETE CASCADE
    ON UPDATE CASCADE);

-- -----------------------------------------------------
-- Table Traspasos
-- -----------------------------------------------------
DROP TABLE IF EXISTS Traspasos ;

CREATE TABLE IF NOT EXISTS Traspasos (
  Fecha_Traspaso DATE NOT NULL,
  ID_Ficha_Jugador INT NOT NULL,
  ID_Club INT NOT NULL,
  Nombre_Organizacion VARCHAR(50) NOT NULL,
  Rol VARCHAR(45) NOT NULL,
  Precio INT NOT NULL,
  PRIMARY KEY (Fecha_Traspaso, ID_Ficha_Jugador, ID_Club, Nombre_Organizacion),
    FOREIGN KEY (ID_Ficha_Jugador)
    REFERENCES Jugador (ID_Ficha_Jugador)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    FOREIGN KEY (ID_Club)
    REFERENCES Club (ID_Club)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    FOREIGN KEY (Nombre_Organizacion)
    REFERENCES Organizacion (Nombre_Organizacion)
    ON DELETE NO ACTION
    ON UPDATE CASCADE);


---------- TRIGGER 1------------

CREATE OR REPLACE FUNCTION check_Anfitrion() RETURNS TRIGGER AS $example_table$
    DECLARE 
            delta_participations integer := (SELECT COUNT(partidos.Nombre_Competicion) 
                      FROM CLUB, PARTICIPA, PARTIDOS
                      WHERE participa.id_partido = partidos.id_partido
                      AND club.id_club = participa.id_club
                      AND club.id_club = NEW.ID_Club);
    BEGIN
            IF delta_participations<3
              THEN
                RAISE EXCEPTION 'Para ser el anfitrion el club deberá al menos jugar en 3 competiciones diferentes';
            END IF;
            RETURN NEW;
    END;
$example_table$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER checkAnfitrion BEFORE INSERT ON Anfitriona
FOR EACH ROW EXECUTE PROCEDURE check_Anfitrion();


---------- TRIGGER 2------------

CREATE OR REPLACE FUNCTION check3equipos() RETURNS TRIGGER AS $example_table$
    DECLARE 
            delta_equipos integer := (SELECT COUNT(id_club) FROM FICHAS WHERE id_ficha_jugador = NEW.id_ficha_jugador);
    BEGIN
            IF delta_equipos=3
              THEN
                RAISE EXCEPTION 'El jugador puede pertenecer a maximo 3 equipos (Club del que pertenece, cedido, y seleccion)';
            END IF;
            RETURN NEW;
    END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER checkEquipo BEFORE INSERT ON Fichas
FOR EACH ROW EXECUTE PROCEDURE check3equipos();


---------- TRIGGER 3 ------------

CREATE OR REPLACE FUNCTION cambioFichaEnTraspaso() RETURNS TRIGGER AS $example_table$
    BEGIN
            IF (NEW.Rol = 'Compra') THEN
              UPDATE FICHAS SET ID_Club = NEW.ID_CLUB WHERE ID_Ficha_Jugador = NEW.ID_Ficha_Jugador;
            END IF;
            RETURN NEW;
    END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER cambioEquipo BEFORE INSERT ON Traspasos
FOR EACH ROW EXECUTE PROCEDURE cambioFichaEnTraspaso();

---------- TRIGGER 4 ------------

CREATE OR REPLACE FUNCTION ajustarPresupuesto() RETURNS TRIGGER AS $example_table$
    BEGIN
            IF (NEW.Rol = 'Compra') THEN
              UPDATE Club SET Presupuesto_Club = Presupuesto_Club - NEW.Precio WHERE ID_CLUB = NEW.ID_CLUB;
            ELSE 
              UPDATE Club SET Presupuesto_Club = Presupuesto_Club + NEW.Precio WHERE ID_CLUB = NEW.ID_CLUB;
            END IF;
            RETURN NEW;
    END;
$example_table$ LANGUAGE plpgsql;

CREATE TRIGGER ajustarPresupuesto BEFORE INSERT ON Traspasos
FOR EACH ROW EXECUTE PROCEDURE ajustarPresupuesto();

-------- Deportes --------------------------

INSERT INTO Deportes VALUES ('Fútbol');
INSERT INTO Deportes VALUES ('Baloncesto');
INSERT INTO Deportes VALUES ('Rugby');
INSERT INTO Deportes VALUES ('Fútbol Americano');
INSERT INTO Deportes VALUES ('Balonmano');

------- Carga de Datos en Organizacion -------------

INSERT INTO Organizacion VALUES ('Real Federación Española de Fútbol (RFEF)', 'España', 1913, 'Fútbol');
INSERT INTO Organizacion VALUES ('National Basketball Association (NBA)', 'Estados Unidos', 1946, 'Baloncesto');
INSERT INTO Organizacion VALUES ('Premier League (PL)', 'Inglaterra', 1992, 'Fútbol');
INSERT INTO Organizacion VALUES ('Real Federación Española de Balonmano (RFEBM)', 'España', 1941, 'Balonmano');
INSERT INTO Organizacion VALUES ('National Football League (NFL)', 'Estados Unidos', 1920, 'Fútbol Americano');
INSERT INTO Organizacion VALUES ('UEFA', 'Europa', 1935, 'Fútbol');

------- Carga de Datos en Competicion -------------

INSERT INTO Competicion VALUES ('La Liga Santander', '2021/2022', 'Real Federación Española de Fútbol (RFEF)');
INSERT INTO Competicion VALUES ('La Copa del Rey', '2021/2022', 'Real Federación Española de Fútbol (RFEF)');
INSERT INTO Competicion VALUES ('NBA', '2021/2022', 'National Basketball Association (NBA)');
INSERT INTO Competicion VALUES ('The Premier League', '2021/2022', 'Premiere League (PL)');
INSERT INTO Competicion VALUES ('Super bowl', '2021/2022', 'National Football League (NFL)');
INSERT INTO Competicion VALUES ('Primera Nacional', '2021/2022', 'Real Federación Española de Balonmano (RFEBM)');
INSERT INTO Competicion VALUES ('UEFA Champions League', '2021/2022', 'UEFA');
INSERT INTO Competicion VALUES ('Trofeo Joan Gamper', '2021/2022', 'Real Federación Española de Fútbol (RFEF)');

------- Carga de Datos en Estadio -------------

INSERT INTO Estadio VALUES (1, 'Ramon Sanchez Pizjuan', 47856);
INSERT INTO Estadio VALUES (2, 'Camp Nou', 89533);
INSERT INTO Estadio VALUES (3, 'TD Garden', 45786);
INSERT INTO Estadio VALUES (4, 'Barclay Center', 23987);
INSERT INTO Estadio VALUES (5, 'Michigan Stadium', 109234);
INSERT INTO Estadio VALUES (6, 'Estadio de Gijon', 109234);
INSERT INTO Estadio VALUES (7, 'Palacio de los Deportes', 10223);
INSERT INTO Estadio VALUES (8, 'Ohio Stadium', 20329);
INSERT INTO Estadio VALUES (9, 'Cotton Bowl', 92678);
INSERT INTO Estadio VALUES (10, 'Old Trafford', 76544);
INSERT INTO Estadio VALUES (11, 'Anfield', 54444);

------- Carga de Datos en Jugador -------------

INSERT INTO Jugador VALUES(2, 'Lebron James', 'Pivot', 50000000, 37);
INSERT INTO Jugador VALUES(4, 'Kevin Durant', 'Alero', 20000000, 33);
INSERT INTO Jugador VALUES(6, 'luka Doncic', 'Base', 5000000, 22);
INSERT INTO Jugador VALUES(8, 'James Harden', 'Escolta', 21500000, 32);
INSERT INTO Jugador VALUES(10, 'Lebron James', 'Ala-Pivot', 4500000, 27);
INSERT INTO Jugador VALUES(10, 'Rudy Gobert', 'Pivot', 510000, 32);
INSERT INTO Jugador VALUES(14, 'Ben DiNucci', 'QB', 410000, 25);
INSERT INTO Jugador VALUES(16, 'Will Grier', 'QB', 1510000, 26);
INSERT INTO Jugador VALUES(18, 'Dak Prescott', 'QB', 410000, 28);
INSERT INTO Jugador VALUES(20, 'Cooper Rush', 'QB', 315000, 28);
INSERT INTO Jugador VALUES(22, 'Corey Clement', 'RB', 1110000, 27);
INSERT INTO Jugador VALUES(24, 'Rico Dowdle', 'RB', 510000, 23);
INSERT INTO Jugador VALUES(26, 'Ezekiel Elliot', 'RB', 710000, 24);
INSERT INTO Jugador VALUES(10, 'Peter McGrain', 'Ala-Pivot', 4500000, 27);
INSERT INTO Jugador VALUES(9, 'Papu Gomez', 'Delantero', 5000000, 27);
INSERT INTO Jugador VALUES(11, 'Gerard Pique', 'Defensa', 7000000, 33);

------ Carga de Datos en Partido -----------

INSERT INTO Partidos VALUES (1, '3-1', '10/23/2021', 'La Liga Santander', '2021/2022', 2);
INSERT INTO Partidos VALUES (2, '0-2', '12/21/2021', 'La Liga Santander', '2021/2022', 1);
INSERT INTO PARTIDOS VALUES (3, '0-3', '17/01/2022', 'La Copa del Rey', '2021/2022', 12);
INSERT INTO PARTIDOS VALUES (4, '0-2', '19/02/2022', 'UEFA Champions League', '2021/2022', 10);

------ Carga de Datos en Personal ---------

INSERT INTO Personal VALUES('4382954X', 'Pepe Morales', 'Administracion', 23000, 38, 2);
INSERT INTO Personal VALUES('4423934E', 'Javier Perez', 'Fisioterapeuta', 25000, 32, 2);
INSERT INTO Personal VALUES('4382954C', 'Manuel Dominguez', 'Medico', 31000, 45, 2);
INSERT INTO Personal VALUES('4389854G', 'Pablo Casanova', 'Coordinador', 40000, 48, 2);
INSERT INTO Personal VALUES('4765954E', 'Noah Sanchez', 'Entrenador', 230000, 45, 2);

----- Carga de Datos en Entrenador --------

INSERT INTO Entrenador VALUES (32, '4765954E');

----- Carga de Datos en Club ------------

INSERT INTO Club VALUES (1, 'FC Barcelona', '1898', 37, 240000000, 2);
INSERT INTO Club VALUES (2, 'Sevilla FC', '1910', 14, 83000000, 1);
INSERT INTO Club VALUES (3, 'CD Tenerife', '1922', 3, 8000000, 12);
INSERT INTO Club VALUES (4, 'Manchester United', '1917', 29, 75000000, 10);

---- Carga de Datos en Fichas ---------

INSERT INTO Fichas VALUES (1, 1);
INSERT INTO Fichas VALUES (1, 3);
INSERT INTO Fichas VALUES (1, 11);
INSERT INTO Fichas VALUES (2, 5);
INSERT INTO Fichas VALUES (2, 7);
INSERT INTO Fichas VALUES (2, 9);

---- Carga de Datos en Participa ------

INSERT INTO Participa VALUES (1, 1);
INSERT INTO Participa VALUES (1, 2);
INSERT INTO Participa VALUES (2, 2);
INSERT INTO Participa VALUES (2, 1);

--- Carga de Datos en Anfitriona -------

INSERT INTO Anfitriona VALUES (1, 'Trofeo Joan Gamper', '2021/2022');

---- Carga de Datos en Traspasos ------

INSERT INTO Traspaso VALUES ('01/28/2022', 1, 1, 'Real Federación Española de Fútbol (RFEF)', 'Vende', 35000000);
INSERT INTO Traspaso VALUES ('01/28/2022', 1, 4, 'Real Federación Española de Fútbol (RFEF)', 'Compra', 35000000);
INSERT INTO Traspaso VALUES ('01/15/2022', 3, 1, 'Real Federación Española de Fútbol (RFEF)', 'Vende', 20000000);
INSERT INTO Traspaso VALUES ('01/15/2022', 3, 4, 'Real Federación Española de Fútbol (RFEF)', 'Compra', 20000000);

