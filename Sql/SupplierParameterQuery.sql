SELECT V.No_ AS SUPPLIER_PARAMETER_ID,
       V.No_ AS SUPPLIER_ID,
       NULL AS CREDIT_LIMIT,
       CASE WHEN V.Blocked = 0 THEN CAST(0 AS BIT)ELSE CAST(1 AS BIT)END AS IS_CREDIT_BLOCKED,
       V.[Payment Terms Code] AS PAYMENT_TERMS_CODE,
       PT.Description AS PAYMENT_TERMS_DESCRIPTION,
       FORMAT(V.[Last Date Modified], 'yyyy-MM-dd HH:mm:ss') AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Vendor] AS V
     LEFT OUTER JOIN dbo.[Navision Company$Payment Terms] AS PT ON V.[Payment Terms Code] = PT.Code;
