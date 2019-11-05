SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT C.No_ AS CUSTOMER_ID,
       Name AS CUSTOMER_NAME,
       C.[IC Partner Code] AS ASSOCIATION_NO,
       CONVERT(CHAR(10), SI.FirstOrderDate, 121) AS ACCOUNT_OPENED_DATE,
       C.[Currency Code] AS DEF_CURRENCY,
       NULL AS MARKET_SECTOR,
       C.[Country_Region Code] AS CUSTOMER_COUNTRY_CODE,
       NULL AS ADDRESS_ID,
       C.Address AS ADDRESS1,
       C.[Address 2] AS ADDRESS2,
       NULL AS ADDRESS3,
       NULL AS CITY,
       C.County AS COUNTY,
       C.[Country_Region Code] AS ADDRESS_COUNTRY,
       C.[Post Code] AS POSTALCODE,
       C.[Phone No_] AS ADDRESS_ID_PHONE,
       C.[Home Page] AS ADDRESS_ID_WWW,
       CONVERT(CHAR(19), C.[Last Date Modified], 121) AS DATE_LAST_MODIFIED
FROM   dbo.[Navision Company$Customer] AS C
       LEFT OUTER JOIN (   SELECT   SI.[Bill-to Customer No_],
                                    MIN(SI.[Order Date]) AS FirstOrderDate
                           FROM     dbo.[Navision Company$Sales Invoice Header] AS SI
                           WHERE    SI.[Bill-to Customer No_] <> '' AND
                                    SI.[Order Date] > '1753-01-01 00:00:00.000'
                           GROUP BY SI.[Bill-to Customer No_]) AS SI ON C.No_ = SI.[Bill-to Customer No_];
