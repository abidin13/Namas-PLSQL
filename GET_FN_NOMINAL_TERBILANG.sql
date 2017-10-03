CREATE OR REPLACE FUNCTION "FN_NOMINAL_TERBILANG" (nominal IN NUMBER) RETURN
VARCHAR2 IS

awal VARCHAR2(100) := ' ';
akhir VARCHAR2(100) := ' ' ;
bilNegatif VARCHAR2(100) := '';
bilPecahan NUMBER(1,0) := 1;
flag BOOLEAN := TRUE;

tmpNominal NUMBER;
bilangan VARCHAR2(40) := NULL;
kesalahan BOOLEAN := FALSE;
hslAkhir VARCHAR2(2000) := NULL;
hslTemp VARCHAR2(2000) := NULL;
var1 VARCHAR2(2000) := NULL;
var2 VARCHAR2(2000) := NULL;
getFlag BOOLEAN := FALSE;

FUNCTION getSatuan (digit IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
    IF digit = '1' THEN RETURN ('Satu ');
    ELSIF digit = '2' THEN RETURN ('Dua ');
    ELSIF digit = '3' THEN RETURN ('Tiga ');
    ELSIF digit = '4' THEN RETURN ('Empat ');
    ELSIF digit = '5' THEN RETURN ('Lima ');
    ELSIF digit = '6' THEN RETURN ('Enam ');
    ELSIF digit = '7' THEN RETURN ('Tujuh ');
    ELSIF digit = '8' THEN RETURN ('Delapan ');
    ELSIF digit = '9' THEN RETURN ('Sembilan ');
    END IF;
END;


FUNCTION getBelasan (digit IN VARCHAR2) RETURN VARCHAR2 IS

BEGIN
    IF digit = '1' THEN RETURN ('Sebelas ');
    ELSIF digit = '2' THEN RETURN ('Dua Belas ');
    ELSIF digit = '3' THEN RETURN ('Tiga Belas ');
    ELSIF digit = '4' THEN RETURN ('Empat Belas ');
    ELSIF digit = '5' THEN RETURN ('Lima Belas ');
    ELSIF digit = '6' THEN RETURN ('Enam Belas ');
    ELSIF digit = '7' THEN RETURN ('Tujuh Belas ');
    ELSIF digit = '8' THEN RETURN ('Delapan Belas ');
    ELSIF digit = '9' THEN RETURN ('Sembilan Belas ');
    ELSIF digit = '0' THEN RETURN ('Sepuluh ');
    END IF;
END;

FUNCTION getEjaSatuan(digit IN VARCHAR2) RETURN VARCHAR2 IS
    temp VARCHAR2(200) := NULL;
    tempChar VARCHAR2(1) := NULL;
BEGIN
    
    tempChar := SUBSTR(digit, 1, 1);
    IF tempChar > '1' THEN
        temp := getSatuan(tempChar);
    ELSIF tempChar = '1' THEN
        temp := getSatuan(tempChar);
    END IF;

    tempChar := SUBSTR(digit, 2, 1);
    IF tempChar > '1' THEN
        temp := temp || getSatuan (tempChar);
    ELSIF tempChar = '1' THEN
        temp := temp || getSatuan (SUBSTR(digit, 3, 1));
    END IF;

    tempChar := SUBSTR(digit, 3, 1);
    IF tempChar > '0' AND SUBSTR(digit, 2, 1) <> '1' THEN
        temp := temp || getSatuan (SUBSTR(digit, 3, 1));
    END IF;
    
    RETURN temp;
END;

FUNCTION getDigit (digit IN VARCHAR2) RETURN VARCHAR2 IS
    temp VARCHAR2(200) := NULL;
    tempChar VARCHAR2(1) := NULL;
BEGIN

    tempChar := SUBSTR(digit, 1, 1);
    IF tempChar > '1' THEN
        temp := getSatuan(tempChar) || 'Ratus ';
    ELSIF tempChar = '1' THEN
        temp := 'Seratus ';
    END IF;

    tempChar := SUBSTR(digit, 2, 1);
    IF tempChar > '1' THEN
        temp := temp || getSatuan (tempChar) || 'Puluh ';
    ELSIF tempChar = '1' THEN
        temp := temp || getBelasan (SUBSTR(digit, 3, 1));
    END IF;

    tempChar := SUBSTR(digit, 3, 1);
    IF tempChar > '0' AND SUBSTR(digit, 2, 1) <> '1' THEN
        temp := temp || getSatuan (SUBSTR(digit, 3, 1));
    END IF;
    
    RETURN temp;
END;

BEGIN
    tmpNominal := nominal;
    IF tmpNominal < 0 THEN
        tmpNominal := ABS(tmpNominal);
        hslAkhir := bilNegatif;
    END IF;
    
    bilangan := TO_CHAR(tmpNominal, '999999999999990.000');

    hslTemp := getDigit(SUBSTR(bilangan, 2, 3));
    IF hslTemp IS NOT NULL THEN
        hslAkhir := hslAkhir || hslTemp || 'Trilyun ';
    END IF;

    hslTemp := getDigit(SUBSTR(bilangan, 5, 3));
    IF hslTemp IS NOT NULL THEN
        hslAkhir := hslAkhir || hslTemp || 'Milyar ';
    END IF;

    hslTemp := getDigit(SUBSTR(bilangan, 8, 3));
    IF hslTemp IS NOT NULL THEN
        hslAkhir := hslAkhir || hslTemp || 'Juta ';
    END IF;

    IF SUBSTR(bilangan, 11, 3) IN ('001', ' 1') THEN
        hslAkhir := hslAkhir || 'Seribu ';
    ELSE
        hslTemp := getDigit(SUBSTR(bilangan, 11, 3));
    
    IF hslTemp IS NOT NULL THEN
        hslAkhir := hslAkhir || hslTemp || 'Ribu ';
    END IF;
    END IF;

    hslTemp := getDigit(SUBSTR(bilangan, 14, 3));
    IF hslTemp IS NOT NULL THEN
        hslAkhir := hslAkhir || hslTemp;
    END IF;
    IF hslAkhir IS NULL AND SUBSTR(bilangan, 16, 1) = '0' THEN
        hslAkhir := 'Nol ';
    END IF;

    bilangan := SUBSTR(Bilangan, 18, 3);
    IF bilangan <> '000' THEN
        IF flag = TRUE THEN
            IF tmpNominal < 1 AND bilangan IN ('500', '250', '125')
            THEN
                hslAkhir := NULL;
            END IF;

        END IF;
        
        IF bilPecahan = 1 AND NOT getFlag THEN
            hslAkhir := hslAkhir || 'Koma ';
            IF SUBSTR(Bilangan, 1, 1) = '0' THEN
                hslAkhir := hslAkhir || 'Nol ';
                IF SUBSTR(Bilangan, 2, 1) = '0' THEN
                    hslAkhir := hslAkhir || 'Nol ';
                END IF;
            END IF;

            Bilangan := RTRIM(Bilangan, ' 0');
            hslAkhir := hslAkhir || getEjaSatuan(LPAD(Bilangan,3,'0')) ;

        ELSIF bilPecahan = 2 AND NOT getFlag
        THEN
            hslAkhir := hslAkhir || 'Koma ';
            Bilangan := RTRIM(Bilangan, ' 0');
            FOR c IN 1 .. LENGTH(bilangan) LOOP
                IF SUBSTR(bilangan, c, 1) = '0' THEN
                    hslAkhir := hslAkhir || 'Nol ';
                ELSE
                    hslAkhir := hslAkhir
                    ||getSatuan(SUBSTR(bilangan,c, 1));
                END IF;
            END LOOP;
        ELSIF NOT getFlag THEN

            IF tmpNominal < 1 THEN
                hslAkhir := NULL;
            END IF;
            Bilangan := RTRIM(Bilangan, ' 0');
            hslAkhir := hslAkhir 
            || getDigit(LPAD(Bilangan,3,'0'));

            IF LENGTH (bilangan) = 1 THEN
                hslAkhir := hslAkhir || 'Persepuluh';
            ELSIF LENGTH (bilangan) = 2 THEN
                hslAkhir := hslAkhir || 'Perseratus';
            ELSE
                hslAkhir := hslAkhir || 'Perseribu';
            END IF;
        END IF;
    END IF;

    hslAkhir := awal || RTRIM(hslAkhir)||akhir;

    SELECT INITCAP(SUBSTR(hslAkhir,1,2)) INTO var1 FROM dual;
    SELECT SUBSTR(hslAkhir,3,LENGTH(hslAkhir)-1) INTO var2 FROM dual;

    hslAkhir := trim(var1)||trim(var2);
    RETURN hslAkhir;
END;
/