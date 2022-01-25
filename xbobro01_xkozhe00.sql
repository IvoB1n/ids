-- DROP TABLES --
DROP TABLE Collectors cascade constraints;
DROP TABLE Orders cascade constraints;
DROP TABLE Magazin cascade constraints;
DROP TABLE MangaVolume cascade constraints;
DROP TABLE Episode cascade constraints;
DROP TABLE Manga cascade constraints;
DROP TABLE IndividualPages cascade constraints;
DROP TABLE CharacterInManga cascade constraints;
DROP TABLE Author cascade constraints;
DROP TABLE Publisher cascade constraints;
DROP TABLE Genre cascade constraints;

DROP TABLE OrderMagazin cascade constraints;
DROP TABLE OrderMangaVolume cascade constraints;
DROP TABLE MagazinEpisode cascade constraints;
DROP TABLE CharacterInEpisode cascade constraints;
DROP TABLE CollectorCharacter cascade constraints;
DROP TABLE MangaCharacter cascade constraints;
DROP TABLE CollectorManga cascade constraints;
DROP TABLE MangaAuthor cascade constraints;
DROP TABLE AuthorGenre cascade constraints;
DROP TABLE MangaGenre cascade constraints;

-- DROP SEQUENCE --
DROP SEQUENCE SEQ_Magazin;

-- CREATE TABLES --
CREATE TABLE Collectors
(
    CollectorId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    UserName VARCHAR(50) NOT NULL,
    UserAddress VARCHAR(50) NOT NULL,
    UserAge NUMBER NOT NULL,
    Email VARCHAR(50)  NOT NULL CHECK(REGEXP_LIKE(Email,'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')),
    Phone VARCHAR(20) UNIQUE NOT NULL CHECK(Phone != ''),
    PRIMARY KEY(CollectorId)
);

CREATE TABLE Orders
(
    OrderId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    OrderDate DATE NOT NULL,
    OrderType VARCHAR(50) NOT NULL,
    OrderStatus VARCHAR(50) NOT NULL,
    CollectorsId NUMBER NOT NULL,
    PRIMARY KEY (OrderId)
);

CREATE TABLE Magazin
(
    MagazinId NUMBER NOT NULL,
    MagazinName VARCHAR(50) NOT NULL,
    PublicationDate DATE NOT NULL,
    MagazinPrice NUMBER NOT NULL,
    PRIMARY KEY (MagazinId)
);

CREATE TABLE MangaVolume
(
    MangaVolumeId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    VolumeName VARCHAR(50) NOT NULL,
    PublicationDate DATE NOT NULL,
    VolumePrice NUMBER NOT NULL,
    PRIMARY KEY (MangaVolumeId)
);

CREATE TABLE Episode
(
    EpisodeId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    EpisodeName VARCHAR(50) NOT NULL,
    EpisodeNumber NUMBER NOT NULL,
    MangaVolId NUMBER NOT NULL,
    InManga NUMBER NOT NULL,
    PRIMARY KEY (EpisodeId)
);

CREATE TABLE Manga
(
    MangaId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    MangaName VARCHAR(50) NOT NULL,
    PublicationDateStart DATE NOT NULL,
    PublicationDateEnd DATE NULL,
    PublisherName VARCHAR(50) NOT NULL,
    PRIMARY KEY (MangaId)
);

CREATE TABLE IndividualPages
(
    IndividualPagesId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    EpisodeId NUMBER NOT NULL,
    PageNumber NUMBER NOT NULL,
    Content BLOB NULL,
    PRIMARY KEY (IndividualPagesId)
);

CREATE TABLE CharacterInManga
(
    CharacterInMangaId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    CharacterName VARCHAR(50) NOT NULL,
    CharacterAge NUMBER, 
    Information VARCHAR(500) NOT NULL,
    FirstOccurrence NUMBER NOT NULL,
    LastOccurrence NUMBER NOT NULL,
    Passed NUMBER NULL,
    PRIMARY KEY (CharacterInMangaId)
);

CREATE TABLE Author
(
    AuthorId NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1),
    AuthorName VARCHAR(50) NOT NULL,
    AuthorAge NUMBER NULL,
    AuthorAddress VARCHAR(100) NULL,
    PRIMARY KEY (AuthorId)
);

CREATE TABLE Publisher
(
    PublisherName VARCHAR(50) NOT NULL,
    PublisherAddress VARCHAR(100) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL CHECK(Email != ''),
    Phone VARCHAR(20) UNIQUE NOT NULL CHECK(Phone != ''),
    PRIMARY KEY (PublisherName)
);

CREATE TABLE Genre
(
    GenreName VARCHAR(50) NOT NULL,
    Information VARCHAR(1000) NOT NULL,
    PRIMARY KEY (GenreName)
);


CREATE TABLE OrderMagazin 
(
    OrderId NUMBER NOT NULL,
    MagazinId NUMBER NOT NULL
);

CREATE TABLE OrderMangaVolume
(
    OrderId NUMBER NOT NULL,
    MangaVolumeId NUMBER NOT NULL
);

CREATE TABLE MagazinEpisode
(
    MagazinId NUMBER NOT NULL,
    EpisodeId NUMBER NOT NULL
);

CREATE TABLE CharacterInEpisode
(
    EpisodeId NUMBER NOT NULL,
    MangaCharacterId NUMBER NOT NULL
);

CREATE TABLE CollectorCharacter
(
    CollectorId NUMBER NOT NULL,
    MangaCharacterId NUMBER NOT NULL
);

CREATE TABLE MangaCharacter 
(
    Manga NUMBER NOT NULL,
    MangaCharacter NUMBER NOT NULL
);

CREATE TABLE CollectorManga 
(
    CollectorId NUMBER NOT NULL,
    MangaId NUMBER NOT NULL
);

CREATE TABLE MangaAuthor 
(
    MangaId NUMBER NOT NULL,
    AuthorId NUMBER NOT NULL
);

CREATE TABLE AuthorGenre
(
    AuthorId NUMBER NOT NULL,
    GenreName VARCHAR(50) NOT NULL
);

CREATE TABLE MangaGenre
(
    MangaId NUMBER NOT NULL,
    GenreName VARCHAR(50) NOT NULL
);

-- CREATE SEQUENCE --
CREATE SEQUENCE SEQ_Magazin INCREMENT BY 1 START WITH 1 NOMAXVALUE MINVALUE 0;

-- CREATE TRIGGERS --

-- trigger for Id(PK) autocomplete
CREATE OR REPLACE TRIGGER TR_Magazin BEFORE INSERT ON Magazin FOR EACH ROW
begin
    if :NEW.MagazinId is null then 
        SELECT SEQ_Magazin.nextval INTO :NEW.MagazinId FROM DUAL; 
    end if; 
end TR_Magazin;
/

-- trigger for price changes
CREATE OR REPLACE TRIGGER displayPriceChanges 
BEFORE DELETE OR INSERT OR UPDATE ON Magazin 
FOR EACH ROW 
WHEN (NEW.MagazinId > 0) 
DECLARE 
    priceDiff NUMBER; 
BEGIN 
    priceDiff := :NEW.MagazinPrice  - :OLD.MagazinPrice; 
    BEGIN
        dbms_output.put_line('Old magazin price: ' || :OLD.MagazinPrice); 
        dbms_output.put_line('New magazin price: ' || :NEW.MagazinPrice); 
        dbms_output.put_line('Magazin price difference: ' || priceDiff); 
    END;
END;
/

-- FOREIGN KEYS --
ALTER TABLE Orders ADD CONSTRAINT FK_Orders FOREIGN KEY (CollectorsId) REFERENCES Collectors (CollectorId);
ALTER TABLE Episode ADD CONSTRAINT FK_Episode_1 FOREIGN KEY (MangaVolId) REFERENCES MangaVolume (MangaVolumeId);
ALTER TABLE Episode ADD CONSTRAINT FK_Episode_2 FOREIGN KEY (InManga) REFERENCES Manga (MangaId);
ALTER TABLE IndividualPages ADD CONSTRAINT FK_IndividualPages FOREIGN KEY (EpisodeId) REFERENCES Episode (EpisodeId);
ALTER TABLE CharacterInManga ADD CONSTRAINT FK_CharacterInManga_1 FOREIGN KEY (FirstOccurrence) REFERENCES IndividualPages (IndividualPagesId);
ALTER TABLE CharacterInManga ADD CONSTRAINT FK_CharacterInManga_2 FOREIGN KEY (LastOccurrence) REFERENCES IndividualPages (IndividualPagesId);
ALTER TABLE Manga ADD CONSTRAINT FK_Publisher FOREIGN KEY (PublisherName) REFERENCES Publisher (PublisherName);
ALTER TABLE OrderMagazin ADD CONSTRAINT FK_OrderMagazin_1 FOREIGN KEY (OrderId) REFERENCES Orders (OrderId);
ALTER TABLE OrderMagazin ADD CONSTRAINT FK_OrderMagazin_2 FOREIGN KEY (MagazinId) REFERENCES Magazin (MagazinId);
ALTER TABLE OrderMangaVolume ADD CONSTRAINT FK_OrderMangaVolume_1 FOREIGN KEY (OrderId) REFERENCES Orders (OrderId);
ALTER TABLE OrderMangaVolume ADD CONSTRAINT FK_OrderMangaVolume_2 FOREIGN KEY (MangaVolumeId) REFERENCES MangaVolume (MangaVolumeId);
ALTER TABLE MagazinEpisode ADD CONSTRAINT FK_MagazinEpisode_1 FOREIGN KEY (MagazinId) REFERENCES Magazin (MagazinId);
ALTER TABLE MagazinEpisode ADD CONSTRAINT FK_MagazinEpisode_2 FOREIGN KEY (EpisodeId) REFERENCES Episode (EpisodeId);
ALTER TABLE CharacterInEpisode ADD CONSTRAINT FK_CharacterInEpisode_1 FOREIGN KEY (EpisodeId) REFERENCES Episode (EpisodeId);
ALTER TABLE CharacterInEpisode ADD CONSTRAINT FK_CharacterInEpisode_2 FOREIGN KEY (MangaCharacterId) REFERENCES CharacterInManga (CharacterInMangaId);
ALTER TABLE CollectorCharacter ADD CONSTRAINT FK_CollectorCharacter_1 FOREIGN KEY (CollectorId) REFERENCES Collectors (CollectorId);
ALTER TABLE CollectorCharacter ADD CONSTRAINT FK_CollectorCharacter_2 FOREIGN KEY (MangaCharacterId) REFERENCES CharacterInManga (CharacterInMangaId);
ALTER TABLE MangaCharacter ADD CONSTRAINT FK_MangaCharacter_1 FOREIGN KEY (Manga) REFERENCES Manga (MangaId);
ALTER TABLE MangaCharacter ADD CONSTRAINT FK_MangaCharacter_2 FOREIGN KEY (MangaCharacter) REFERENCES CharacterInManga (CharacterInMangaId);
ALTER TABLE CollectorManga ADD CONSTRAINT FK_CollectorManga_1 FOREIGN KEY (CollectorId) REFERENCES Collectors (CollectorId);
ALTER TABLE CollectorManga ADD CONSTRAINT FK_CollectorManga_2 FOREIGN KEY (MangaId) REFERENCES Manga (MangaId);
ALTER TABLE MangaAuthor ADD CONSTRAINT FK_MangaAuthor_1 FOREIGN KEY (MangaId) REFERENCES Manga (MangaId);
ALTER TABLE MangaAuthor ADD CONSTRAINT FK_MangaAuthor_2 FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId);
ALTER TABLE AuthorGenre ADD CONSTRAINT FK_AuthorGenre_1 FOREIGN KEY (AuthorId) REFERENCES Author (AuthorId);
ALTER TABLE AuthorGenre ADD CONSTRAINT FK_AuthorGenre_2 FOREIGN KEY (GenreName) REFERENCES Genre (GenreName);
ALTER TABLE MangaGenre ADD CONSTRAINT FK_MangaGenre_1 FOREIGN KEY (MangaId) REFERENCES Manga (MangaId);
ALTER TABLE MangaGenre ADD CONSTRAINT FK_MangaGenre_2 FOREIGN KEY (GenreName) REFERENCES Genre (GenreName);


-- INSERTING --
INSERT INTO Author (AuthorName, AuthorAge, AuthorAddress) VALUES ('Naoshi Arakawa', NULL, 'Japan');
INSERT INTO Author (AuthorName, AuthorAge, AuthorAddress) VALUES ('Hadzime Isaiama', '34', 'Japan');

INSERT INTO Genre (GenreName, Information) VALUES ('Drama', 'Drama is the specific mode of fiction represented in performance: a play, opera, mime, ballet, etc., performed in a theatre, or on radio or television. Considered as a genre of poetry in general, the dramatic mode has been contrasted with the epic and the lyrical modes ever since Aristotles Poetics —the earliest work of dramatic theory. The term drama comes from a Greek word meaning action (Classical Greek: δρᾶμα, drama), which is derived from I do (Classical Greek: δράω, drao). The two masks associated with drama represent the traditional generic division between comedy and tragedy.');
INSERT INTO Genre (GenreName, Information) VALUES ('Anti-utopia', 'A dystopia is a fictional community or society that is undesirable or frightening. It is often treated as an antonym of utopia, a term that was coined by Sir Thomas More and figures as the title of his best known work, published in 1516, which created a blueprint for an ideal society with minimal crime, violence and poverty. But the relationship between utopia and dystopia is more complex than this, as there exist utopian elements in many dystopias, and vice-versa.'); 

INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Ivan', 'Ulice 61500, Brno', 30, 'xbobro01@fit.vutbr.cz', '+4200000000000');
INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Dmitrii', 'Ulice 62000, Brno', 16, 'xkozhe00@fit.vutbr.cz', '+420111111111');
INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Snezhana', 'Ulice 62000, Brno', 20, 'xlogin01@fit.vutbr.cz', '+420111111222');
INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Yahor', 'Ulice 9000, Bobrujsk', 93, 'xplagiat0b@fit.vutbr.cz', '+435151351535');
INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Lena', 'unknown country', 13, 'xcaras00@fit.vutbr.cz', '+420111118822');
INSERT INTO Collectors (UserName, UserAddress, UserAge, Email, Phone) VALUES ('Viktoria', 'PPV, Tadjikiston', 42, 'xlogin00@fit.vutbr.cz', '+420177111222');

INSERT INTO Publisher (PublisherName, PublisherAddress, Email, Phone) VALUES ('Kodansha', 'Japan, Tokio', 'kodansha.co.jp', '+894256899865');
INSERT INTO Publisher (PublisherName, PublisherAddress, Email, Phone) VALUES ('Dudoser', 'Russia, Tokio', 'lupus.su', '+2552462466');

INSERT INTO Manga (MangaName, PublicationDateStart, PublicationDateEnd, PublisherName) VALUES ('Shigatsu wa Kimi no Uso (Your Lie in April)', DATE '2017-01-02', DATE '2020-01-22', 'Kodansha');
INSERT INTO Manga (MangaName, PublicationDateStart, PublicationDateEnd, PublisherName) VALUES ('Shingeki no Kyojin (Attack on titan)', DATE '2017-01-02', DATE '2020-01-22', 'Kodansha');
INSERT INTO Manga (MangaName, PublicationDateStart, PublicationDateEnd, PublisherName) VALUES ('Naruto', DATE '2010-01-02', DATE '2019-01-22', 'Kodansha');
INSERT INTO Manga (MangaName, PublicationDateStart, PublicationDateEnd, PublisherName) VALUES ('Boruto', DATE '2017-01-02', DATE '2021-01-22', 'Kodansha');

INSERT INTO MangaVolume (VolumeName, PublicationDate, VolumePrice) VALUES ('Volume 1', DATE '2018-01-02', 10);
INSERT INTO MangaVolume (VolumeName, PublicationDate, VolumePrice) VALUES ('Volume 2', DATE '2018-01-10', 15);

INSERT INTO Episode (EpisodeName, EpisodeNumber, MangaVolId, InManga) VALUES ('Monotone/Colorful', 1, 1, 1);
INSERT INTO Episode (EpisodeName, EpisodeNumber, MangaVolId, InManga) VALUES ('Friend A', 2, 1, 1);

INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 1', DATE '2018-01-02', 10);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 2', DATE '2018-01-05', 45);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 3', DATE '2018-01-02', 60);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 4', DATE '2018-01-05', 56);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 4', DATE '2018-01-15', 56);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 4', DATE '2018-01-16', 56);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 5', DATE '2018-01-17', 29);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 5', DATE '2018-01-18', 29);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 6', DATE '2018-01-19', 71);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 7', DATE '2018-01-20', 34);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 1', DATE '2018-01-21', 10);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 8', DATE '2018-01-22', 19);
INSERT INTO Magazin (MagazinName, PublicationDate, MagazinPrice) VALUES ('Magazin 8', DATE '2018-01-23', 19);

INSERT INTO IndividualPages (EpisodeId, PageNumber) VALUES (1, 12);
INSERT INTO IndividualPages (EpisodeId, PageNumber) VALUES (1, 13);

INSERT INTO CharacterInManga (CharacterName, CharacterAge, Information, FirstOccurrence, LastOccurrence, Passed) VALUES ('Eren Yeger', 14, 'Information about Eren', 1, 2, NULL);
INSERT INTO CharacterInManga (CharacterName, CharacterAge, Information, FirstOccurrence, LastOccurrence, Passed) VALUES ('Mikasa Akkerman', 14, 'Information about Mikasa', 1, 1, NULL);
INSERT INTO CharacterInManga (CharacterName, CharacterAge, Information, FirstOccurrence, LastOccurrence, Passed) VALUES ('Naruto Uzumaki', 16, 'Jsem stanu HOKAGE', 1, 1, NULL);
INSERT INTO CharacterInManga (CharacterName, CharacterAge, Information, FirstOccurrence, LastOccurrence, Passed) VALUES ('Naruto Uzumaki', 28, 'Jsem HOKAGE', 1, 1, NULL);
INSERT INTO CharacterInManga (CharacterName, Information, FirstOccurrence, LastOccurrence, Passed) VALUES ('Ococuke Kaguja', 'Not Information', 1, 1, NULL);

INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-01-11', 'On-line', 'Done', 1);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-12', 'On-line + book', 'In process', 2);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-13', 'On-line + book', 'In process', 2);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-14', 'On-line + book', 'Canceled', 2);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-15', 'On-line + book', 'In process', 3);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-15', 'On-line + book', 'Done', 2);
INSERT INTO Orders (OrderDate, OrderType, OrderStatus, CollectorsId) VALUES (DATE '2018-03-15', 'On-line + book', 'In process', 1);


-- DOTAZY SELECT --
-- SQL skript obsahující dotazy SELECT musí obsahovat konkrétně alespoň dva dotazy
-- využívající spojení dvou tabulek

-- information to send notification about order status
SELECT  Collectors.UserName, Collectors.Phone, Collectors.Email, Orders.OrderStatus
FROM Orders JOIN Collectors ON Orders.OrderId = Collectors.CollectorID
ORDER BY Orders.OrderStatus;

-- which publisher publish manga from certain author
SELECT Manga.MangaName, Manga.PublisherName, AuthorName
FROM Author JOIN Manga ON Author.AuthorId = Manga.MangaId
ORDER BY Author.AuthorName;

-- jeden využívající spojení tří tabulek, 

-- find information about charecter in certain episode and certain manga
SELECT CharacterInManga.CharacterName, CharacterInManga.CharacterAge, CharacterInManga.Information, Manga.MangaName, Episode.EpisodeNumber
FROM CharacterInManga 
JOIN Episode ON CharacterInManga.CharacterInMangaId = Episode.EpisodeId
JOIN Manga ON CharacterInManga.CharacterInMangaId = Manga.MangaId
ORDER BY CharacterInManga.CharacterName;

-- dva dotazy s klauzulí GROUP BY a agregační funkcí

-- return an oldest version of characters
SELECT CharacterName, MAX( CharacterAge )
FROM CharacterInManga GROUP BY CharacterName
ORDER BY CharacterName;

-- returns the minimum price for each magazine in the given price range.
SELECT MagazinName, MIN(MagazinPrice)
FROM Magazin 
GROUP BY MagazinName
HAVING MIN(MagazinPrice) BETWEEN 40 AND 70
ORDER BY MagazinName;

--jeden dotaz obsahující predikát EXISTS

-- search for chars if they're age is present

SELECT CharacterName, CharacterAge, Information
FROM CharacterInManga
WHERE EXISTS (
        SELECT *
        FROM Manga
        WHERE CharacterInManga.CharacterInMangaId = Manga.MangaId
    );



--jeden dotaz s predikátem IN s vnořeným selectem (nikoliv IN s množinou konstantních dat).

-- search for order status, where status is 'in progress'

SELECT OrderId, UserName, CollectorId, OrderStatus
FROM Orders FULL OUTER JOIN Collectors ON Orders.CollectorsId = Collectors.CollectorID
WHERE OrderStatus IN (
    'In process'
)
ORDER BY OrderId;

select * from ORDERS;
select * from COLLECTORS;
select * from MAGAZIN;
select * from CHARACTERINMANGA;
select * from Episode;

-- INDEX AND EXPLAIN PLAN --

EXPLAIN PLAN SET STATEMENT_ID = 'performanceAnalysisBefore' FOR
    SELECT Collectors.CollectorId, Collectors.UserName, Collectors.UserAge, COUNT(Orders.CollectorsId)
    FROM Orders LEFT JOIN Collectors ON (Orders.CollectorsId = Collectors.CollectorId) WHERE Collectors.UserAge > 18
    GROUP BY (Collectors.CollectorId, Collectors.UserName, Collectors.UserAge);
SELECT * FROM TABLE(DBMS_XPLAN.display);

CREATE INDEX performanceIndex ON Collectors (UserAge);

EXPLAIN PLAN SET STATEMENT_ID = 'performanceAnalysisAfter' FOR
    SELECT Collectors.CollectorId, Collectors.UserName, Collectors.UserAge, COUNT(Orders.CollectorsId)
    FROM Orders LEFT JOIN Collectors ON (Orders.CollectorsId = Collectors.CollectorId) WHERE Collectors.UserAge > 18
    GROUP BY (Collectors.CollectorId, Collectors.UserName, Collectors.UserAge);
SELECT * FROM TABLE(DBMS_XPLAN.display);

DROP INDEX performanceIndex;

-- PRIVILEGES --
GRANT ALL PRIVILEGES ON Collectors TO xkozhe00;
GRANT ALL PRIVILEGES ON Orders TO xkozhe00;
GRANT ALL PRIVILEGES ON Magazin TO xkozhe00;
GRANT ALL PRIVILEGES ON MangaVolume TO xkozhe00;
GRANT ALL PRIVILEGES ON Episode TO xkozhe00;
GRANT ALL PRIVILEGES ON Manga TO xkozhe00;
GRANT ALL PRIVILEGES ON IndividualPages TO xkozhe00;
GRANT ALL PRIVILEGES ON CharacterInManga TO xkozhe00;
GRANT ALL PRIVILEGES ON Author TO xkozhe00;
GRANT ALL PRIVILEGES ON Publisher TO xkozhe00;
GRANT ALL PRIVILEGES ON Genre TO xkozhe00;
GRANT ALL PRIVILEGES ON OrderMagazin TO xkozhe00;
GRANT ALL PRIVILEGES ON OrderMangaVolume TO xkozhe00;
GRANT ALL PRIVILEGES ON MagazinEpisode TO xkozhe00;
GRANT ALL PRIVILEGES ON CharacterInEpisode TO xkozhe00;
GRANT ALL PRIVILEGES ON CollectorCharacter TO xkozhe00;
GRANT ALL PRIVILEGES ON MangaCharacter TO xkozhe00;
GRANT ALL PRIVILEGES ON CollectorManga TO xkozhe00;
GRANT ALL PRIVILEGES ON MangaAuthor TO xkozhe00;
GRANT ALL PRIVILEGES ON AuthorGenre TO xkozhe00;
GRANT ALL PRIVILEGES ON MangaGenre TO xkozhe00;


-- MATERIALIZED --
DROP MATERIALIZED VIEW MV_notify;

CREATE MATERIALIZED VIEW LOG ON Collectors
    WITH PRIMARY KEY
    INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW MV_notify
    BUILD IMMEDIATE        
    REFRESH FAST ON COMMIT
    AS SELECT CollectorId, UserName, Email, Phone, UserAddress, UserAge FROM Collectors;

SELECT * from MV_notify;
GRANT SELECT ON MV_notify to xkozhe00;

-- CREATE PROCEDURES --
-- Procedure for changing prices for magazines at the request of the publisher
CREATE OR REPLACE Procedure UpdateMagazin
   ( name_in IN VARCHAR, price_in IN NUMBER )
 IS
    MPrice number;   
    cursor c1 is
    SELECT MagazinPrice
    FROM Magazin
    WHERE MagazinName = name_in;
 
BEGIN

    OPEN c1;
    FETCH c1 INTO MPrice;
 
    IF c1%notfound THEN
        MPrice := 9999;
    ELSE
        MPrice := price_in;
        UPDATE Magazin SET MagazinPrice = MPrice WHERE Magazin.MagazinName = name_in;
    
    END IF;
   
     CLOSE c1;
 
EXCEPTION
WHEN OTHERS THEN
    raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/

-- Fixed-trade price control procedure
CREATE OR REPLACE PROCEDURE PriceCorrelation
  ( MagId IN Magazin.MagazinId%TYPE, price IN NUMBER )
  IS
    minNum CONSTANT NUMBER := 15;
    maxNum CONSTANT NUMBER := 70;
    invalid EXCEPTION;
BEGIN
    IF price < minNum THEN
        UPDATE Magazin SET MagazinPrice = minNum WHERE Magazin.MagazinId = MagId;
    END IF;
    
      IF price > maxNum THEN
        UPDATE Magazin SET MagazinPrice = maxNum WHERE Magazin.MagazinId = MagId;
    END IF;
    
      IF SQL%ROWCOUNT = 0 THEN RAISE NO_DATA_FOUND; 
      ELSE RAISE invalid;
      END IF;
EXCEPTION
    WHEN invalid THEN 
    dbms_output.put_line('The magazin is invalid');
    WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('No magazins in system:' || TO_CHAR(MagId));
    WHEN OTHERS THEN
    raise_application_error(-20001,'An error was encountered - '||SQLCODE||' -ERROR- '||SQLERRM);
END;
/

SELECT * FROM MAGAZIN;

BEGIN
    UpdateMagazin('Magazin 5', 88);
END;
/
SELECT * FROM MAGAZIN;

DECLARE
    newMagazinId NUMBER;
BEGIN
    newMagazinId := 3;
    PriceCorrelation(newMagazinId, 150);
END;
/
SELECT * FROM MAGAZIN;

BEGIN
    dbms_output.put_line(''); 
END;
/