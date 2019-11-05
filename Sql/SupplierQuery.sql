SELECT V.No_ AS SUPPLIER_ID,
       NULLIF(V.[Purchaser Code], '') AS BUYER_ID,
       NULLIF(V.[Country_Region Code], '') AS COUNTRY_ID,
       ISNULL(NULLIF(V.[Currency Code], N''), GLS.[LCY Code]) AS CURRENCY_ID,
       NULL AS DEFAULT_ADDRESS_ID,
       NULLIF(SP.Name, '') AS BUYER_NAME,
       V.Name AS SUPPLIER_NAME,
       CONVERT(CHAR(10), PIH.FirstOrderDate, 121) AS ACCOUNT_OPENED_DATE,
       NULLIF(V.[IC Partner Code], '') AS ASSOCIATION_REFERENCE,
       NULLIF(V.[Phone No_], '') AS PHONE_NUMBER,
       NULLIF(V.[Home Page], '') AS WEBSITE_URL,
       NULLIF(V.Address, '') AS ADDRESS1,
       NULLIF(V.[Address 2], '') AS ADDRESS2,
       NULL AS ADDRESS3,
       NULLIF(V.City, '') AS CITY,
       NULLIF(V.County, '') AS STATE_PROVINCE,
       NULL AS COUNTRY,
       NULLIF(V.[Post Code], '') AS POSTAL_CODE,
       CASE WHEN V.[Vendor Posting Group] = '' OR V.[Vendor Posting Group] = 'INTERNAL' THEN 1 ELSE 0 END AS IS_INTERNAL,
       NULL AS LOADED_BY,
       NULL AS CREATED_BY,
       NULL AS MODIFIED_BY,
       CONVERT(CHAR(19), GETDATE(), 121) AS DATE_LOADED,
       CONVERT(CHAR(19), PIH.FirstOrderDate, 121) AS DATE_CREATED,
       CONVERT(CHAR(19), V.[Last Date Modified], 121) AS DATE_MODIFIED
FROM dbo.[Navision Company$Vendor] AS V
     LEFT OUTER JOIN dbo.[Navision Company$Salesperson_Purchaser] AS SP ON V.[Purchaser Code] = SP.Code
     LEFT OUTER JOIN( SELECT PIH.[Pay-to Vendor No_],
                             MIN(PIH.[Order Date]) AS FirstOrderDate
                      FROM dbo.[Navision Company$Purch_ Inv_ Header] AS PIH
                      WHERE PIH.[Pay-to Vendor No_] <> ''
                            AND PIH.[Order Date] > '1753-01-01 00:00:00.000'
                      GROUP BY PIH.[Pay-to Vendor No_] ) AS PIH ON V.No_ = PIH.[Pay-to Vendor No_]
     OUTER APPLY dbo.[Navision Company$General Ledger Setup] AS GLS
WHERE V.No_ IS NOT NULL
      AND V.No_ <> '';
