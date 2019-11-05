SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT C.No_ AS CUSTOMER_PARAMETER_ID,
       C.No_ AS CUSTOMER_ID,
       CAST(C.[Credit Limit (LCY)] AS DECIMAL(38, 4)) AS CREDIT_LIMIT,
       CASE WHEN C.Blocked = 0 THEN CAST(0 AS BIT)ELSE CAST(1 AS BIT)END AS IS_CREDIT_BLOCKED,
       C.[Payment Terms Code] AS PAYMENT_TERMS_CODE,
       PT.Description AS PAYMENT_TERMS_DESCRIPTION,
       FORMAT(C.[Last Date Modified], 'yyyy-MM-dd HH:mm:ss') AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Customer] AS C
     LEFT OUTER JOIN dbo.[Navision Company$Payment Terms] AS PT ON C.[Payment Terms Code] = PT.Code;