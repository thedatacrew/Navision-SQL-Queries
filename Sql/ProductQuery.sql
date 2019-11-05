SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT I.No_ AS ITEM_ID,
       I.No_ AS PRODUCT_CODE,
       I.Description AS DESCRIPTION,
       IC.Description AS CATEGORY,
       I.[Base Unit of Measure] AS UNIT_OF_MEASURE,
       CONVERT(CHAR(19), I.[Created Datetime], 121) AS DATE_CREATED,
       CONVERT(
           CHAR(19),
           DATETIMEFROMPARTS(
               DATEPART(YEAR, I.[Last Date Modified]),
               DATEPART(MONTH, I.[Last Date Modified]),
               DATEPART(DAY, I.[Last Date Modified]),
               DATEPART(HOUR, I.[Last Time Modified]),
               DATEPART(MINUTE, I.[Last Time Modified]),
               DATEPART(SECOND, I.[Last Time Modified]),
               DATEPART(MILLISECOND, I.[Last Time Modified])),
           121) AS DATE_LAST_MODIFIED
FROM dbo.[Navision Company$Item] AS I
     LEFT OUTER JOIN dbo.[Navision Company$Item Category] AS IC ON I.[Item Category Code] = IC.Code;
