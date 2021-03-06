/****** Object:  StoredProcedure [dbo].[COMMON$SP_VALIDATE_CONVERSIONDATA_RI]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
------------------------------------------------------------------------------------------------------------------
Program Name		: COMMON$SP_VALIDATE_CONVERSIONDATA_RI
Programmer Name		: Protech Solutions, Inc. RAJKUMAR RAJENDRAN
Description_TEXT	: This Procedure loads all the Referential Integrity data issue in CRIR_Y1 table.
Developed On		: 02/02/2011
Modified By			:
Modified On			: 02/08/2013
Version No			: 1.0
------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[COMMON$SP_VALIDATE_CONVERSIONDATA_RI]
 @Ad_Conversion_DATE DATE
AS
 BEGIN
  BEGIN TRY
   DECLARE @Ls_Sql_TEXT         VARCHAR(200),
           @Li_Rowcount_QNTY    SMALLINT,
           @Ln_CaseWelfare_IDNO NUMERIC(10);

   SELECT @Ad_Conversion_DATE AS Conversion_DATE

   SET @Ls_Sql_TEXT = '';

   ------------
   IF EXISTS(SELECT 1
               FROM SYS.OBJECTS
              WHERE Name = 'CRIR_Y1_BK'
                AND TYPE = 'U')
    BEGIN
     INSERT INTO CRIR_Y1_BK
     SELECT *
       FROM CRIR_Y1
    END

   IF NOT EXISTS(SELECT 1
                   FROM SYS.OBJECTS
                  WHERE Name = 'CRIR_Y1_BK'
                    AND TYPE = 'U')
    BEGIN
     IF EXISTS(SELECT TOP 1 *
                 FROM CRIR_Y1)
      BEGIN
       SELECT *
         INTO CRIR_Y1_BK
         FROM CRIR_Y1;
      END
    END

   IF EXISTS(SELECT TOP 1 *
               FROM CRIR_Y1)
    BEGIN
     DELETE FROM CRIR_Y1;
    END

   -----------
   IF EXISTS(SELECT 1
               FROM SYS.OBJECTS
              WHERE Name = 'CRIRLog_Y1_BK'
                AND TYPE = 'U')
    BEGIN
     --DROP TABLE CRIRLog_Y1_BK;
     INSERT INTO CRIRLog_Y1_BK
     SELECT *
       FROM CRIRLog_Y1
    END

   IF NOT EXISTS(SELECT 1
                   FROM SYS.OBJECTS
                  WHERE Name = 'CRIRLog_Y1_BK'
                    AND TYPE = 'U')
    BEGIN
     IF EXISTS(SELECT TOP 1 *
                 FROM CRIRLog_Y1)
      BEGIN
       SELECT *
         INTO CRIRLog_Y1_BK
         FROM CRIRLog_Y1;
      END
    END

   IF EXISTS(SELECT TOP 1 *
               FROM CRIRLog_Y1)
    BEGIN
     DELETE FROM CRIRLog_Y1;
    END

   ------------
   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          'COMMON$SP_VALIDATE_CONVERSIONDATA_RI Execution IS Started. Please Wait....',
          'S';

   SET @Ls_Sql_TEXT = 'R.I (ACEN_SORD) ACEN_Y1 KEY NOT IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ACEN_SORD) ACEN_Y1 KEY NOT IN SORD_Y1',
          'ENFORCEMENT',
          'ACEN_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM ACEN_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM SORD_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (AHIS_DEMO) AHIS_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (AHIS_DEMO) AHIS_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'AHIS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BSUP_CASE) BSUP_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BSUP_CASE) BSUP_Y1.Case_IDNO NOT IN CASE_Y1',
          'FINANCIAL',
          'BSUP_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '2'
     FROM BSUP_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BSUP_GLEV) BSUP_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BSUP_GLEV) BSUP_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'BSUP_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM BSUP_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (CASE_COPT) CASE_Y1.County_IDNO NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CASE_COPT) CASE_Y1.County_IDNO NOT IN COPT_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'County_IDNO',
          a.County_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.County_IDNO = b.County_IDNO)
    GROUP BY County_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CASE_OFIC) CASE_Y1.Office_IDNO NOT IN OFIC_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CASE_OFIC) CASE_Y1.Office_IDNO NOT IN OFIC_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Office_IDNO',
          a.Office_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OFIC_Y1 b
                       WHERE a.Office_IDNO = b.Office_IDNO)
    GROUP BY Office_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CASE_DCKT) CASE_Y1.File_ID NOT IN DCKT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (CASE_DCKT) CASE_Y1.File_ID NOT IN DCKT_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'File_ID',
          a.File_ID,
          COUNT (DISTINCT File_ID),
          '1'
     FROM CASE_Y1 a
    WHERE LTRIM(RTRIM (File_ID)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM DCKT_Y1 b
                       WHERE a.File_ID = b.File_ID)
    GROUP BY File_ID;

   SET @Ls_Sql_TEXT = 'R.I (CMEM_CASE) CMEM_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CMEM_CASE) CMEM_Y1.Case_IDNO NOT IN CASE_Y1',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM CMEM_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CMEM_DEMO) CMEM_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CMEM_DEMO) CMEM_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM CMEM_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CWRK_CASE) CWRK_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CWRK_CASE) CWRK_Y1.Case_IDNO NOT IN CASE_Y1',
          'CASE MANAGEMENT',
          'CWRK_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '2'
     FROM CWRK_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CWRK_OFIC) CWRK_Y1.Office_IDNO NOT IN OFIC_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CWRK_OFIC) CWRK_Y1.Office_IDNO NOT IN OFIC_Y1',
          'CASE MANAGEMENT',
          'CWRK_Y1',
          'Office_IDNO',
          a.Office_IDNO,
          COUNT (1),
          '2'
     FROM CWRK_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OFIC_Y1 b
                       WHERE a.Office_IDNO = b.Office_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Office_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CWRK_ROLE) CWRK_Y1.Role_ID NOT IN ROLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CWRK_ROLE) CWRK_Y1.Role_ID NOT IN ROLE_Y1',
          'CASE MANAGEMENT',
          'CWRK_Y1',
          'Role_ID',
          a.Role_ID,
          COUNT (1),
          '2'
     FROM CWRK_Y1 a
    WHERE LTRIM(RTRIM (a.Role_ID)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM ROLE_Y1 b
                       WHERE a.Role_ID = b.Role_ID)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Role_ID;

   SET @Ls_Sql_TEXT = 'R.I (CHLD_OTHP) CHLD_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CHLD_OTHP) CHLD_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1',
          'FINANCIAL',
          'CHLD_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM CHLD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 c
                       WHERE a.CheckRecipient_ID = c.Fips_CODE
                         AND EndValidity_DATE = '12/31/9999')
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 d
                       WHERE a.CheckRecipient_ID = d.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'R.I (CHLD_CASE) CHLD_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CHLD_CASE) CHLD_Y1.Case_IDNO NOT IN CASE_Y1',
          'FINANCIAL',
          'CHLD_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM CHLD_Y1 a
    WHERE a.Case_IDNO <> 0
      AND NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CHLD_GLEV) CHLD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CHLD_GLEV) CHLD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'CHLD_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM CHLD_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (CBOR_DEMO) CBOR_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CBOR_DEMO) CBOR_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'CBOR_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM CBOR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (CBOR_SORD) CBOR_Y1 KEY NOT IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CBOR_SORD) CBOR_Y1 KEY NOT IN SORD_Y1',
          'ENFORCEMENT',
          'CBOR_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM CBOR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM SORD_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DCRS_DEMO) DCRS_Y1.CheckRecipient_ID NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DCRS_DEMO) DCRS_Y1.CheckRecipient_ID NOT IN DEMO_Y1',
          'FINANCIAL',
          'DCRS_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM DCRS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'R.I (DCRS_GLEV) DCRS_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DCRS_GLEV) DCRS_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'DCRS_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM DCRS_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (DINS_DEMO) DINS_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DINS_DEMO) DINS_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'DINS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM DINS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DINS_OTHP) DINS_Y1.OthpInsurance_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DINS_OTHP) DINS_Y1.OthpInsurance_IDNO NOT IN OTHP_Y1',
          'ENFORCEMENT',
          'DINS_Y1',
          'OthpInsurance_IDNO',
          a.OthpInsurance_IDNO,
          COUNT (1),
          '1'
     FROM DINS_Y1 a
    WHERE LTRIM(RTRIM (a.OthpInsurance_IDNO)) <> 0
      AND EndValidity_DATE = '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpInsurance_IDNO = b.OtherParty_IDNO
                         AND b.TypeOthp_CODE = 'I'
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY OthpInsurance_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DINS_DEMO) DINS_Y1.ChildMCI_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DINS_DEMO) DINS_Y1.ChildMCI_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'DINS_Y1',
          'ChildMCI_IDNO',
          a.ChildMCI_IDNO,
          COUNT (1),
          '1'
     FROM DINS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.ChildMCI_IDNO = b.MemberMci_IDNO)
    GROUP BY ChildMCI_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DISH_DEMO) DISH_Y1.CasePayorMCI_IDNO NOT IN CASE_Y1, DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DISH_DEMO) DISH_Y1.CasePayorMCI_IDNO NOT IN CASE_Y1, DEMO_Y1',
          'FINANCIAL',
          'DISH_Y1',
          'CasePayorMCI_IDNO',
          a.CasePayorMCI_IDNO,
          COUNT (1),
          '1'
     FROM DISH_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.CasePayorMCI_IDNO = b.Case_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 c
                       WHERE a.CasePayorMCI_IDNO = c.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CasePayorMCI_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DISH_GLEV) DISH_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DISH_GLEV) DISH_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'DISH_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM DISH_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (DPRS_DCKT) DPRS_Y1.File_ID NOT IN DCKT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (DPRS_DCKT) DPRS_Y1.File_ID NOT IN DCKT_Y1',
          'FINANCIAL',
          'DPRS_Y1',
          'File_ID',
          a.File_ID,
          COUNT (DISTINCT File_ID),
          '1'
     FROM DPRS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DCKT_Y1 b
                       WHERE a.File_ID = b.File_ID)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY File_ID;

   SET @Ls_Sql_TEXT = 'R.I (DPRS_COPT) DPRS_Y1.County_IDNO NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DPRS_COPT) DPRS_Y1.County_IDNO NOT IN COPT_Y1',
          'FINANCIAL',
          'DPRS_Y1',
          'County_IDNO',
          a.County_IDNO,
          COUNT (1),
          '1'
     FROM DPRS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.County_IDNO = b.County_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY County_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DPRS_OTHP) DPRS_Y1.OthpParty_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (DPRS_OTHP) DPRS_Y1.OthpParty_IDNO NOT IN OTHP_Y1',
          'FINANCIAL',
          'DPRS_Y1',
          'DocketPerson_IDNO',
          a.DocketPerson_IDNO,
          COUNT (DISTINCT a.DocketPerson_IDNO),
          '1'
     FROM DPRS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.DocketPerson_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 c
                       WHERE a.DocketPerson_IDNO = c.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY DocketPerson_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DCKT_COPT) DCKT_Y1.County_IDNO NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DCKT_COPT) DCKT_Y1.County_IDNO NOT IN COPT_Y1',
          'FINANCIAL',
          'DCKT_Y1',
          'County_IDNO',
          a.County_IDNO,
          COUNT (1),
          '2'
     FROM DCKT_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.County_IDNO = b.County_IDNO)
    GROUP BY County_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (EFTR_OTHP) EFTR_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EFTR_OTHP) EFTR_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1',
          'FINANCIAL',
          'EFTR_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM EFTR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 c
                       WHERE a.CheckRecipient_ID = c.Fips_CODE
                         AND EndValidity_DATE = '12/31/9999')
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 d
                       WHERE a.CheckRecipient_ID = CAST(d.OtherParty_IDNO AS VARCHAR(9))
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'R.I (EFTR_GLEV) EFTR_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EFTR_GLEV) EFTR_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'EFTR_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM EFTR_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (EHIS_DEMO) EHIS_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EHIS_DEMO) EHIS_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM EHIS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (EHIS_OTHP) EHIS_Y1.OthpPartyEmpl_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EHIS_OTHP) EHIS_Y1.OthpPartyEmpl_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'OthpPartyEmpl_IDNO',
          a.OthpPartyEmpl_IDNO,
          COUNT (1),
          '1'
     FROM EHIS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpPartyEmpl_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY OthpPartyEmpl_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (ESEM_EEMA) ESEM_Y1.TypeEntity_CODE NOT IN EEMA_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ESEM_EEMA) ESEM_Y1.TypeEntity_CODE NOT IN EEMA_Y1',
          'FINANCIAL',
          'ESEM_Y1',
          'TypeEntity_CODE',
          a.TypeEntity_CODE,
          COUNT (1),
          '1'
     FROM ESEM_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM EEMA_Y1 b
                       WHERE a.TypeEntity_CODE = b.TypeEntity_CODE)
    GROUP BY TypeEntity_CODE;

   SET @Ls_Sql_TEXT = 'R.I (ESEM_EEMA) ESEM_Y1.EventFunctionalSeq_NUMB NOT IN EEMA_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ESEM_EEMA) ESEM_Y1.EventFunctionalSeq_NUMB NOT IN EEMA_Y1',
          'FINANCIAL',
          'ESEM_Y1',
          'EventFunctionalSeq_NUMB',
          a.EventFunctionalSeq_NUMB,
          COUNT (1),
          '1'
     FROM ESEM_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM EEMA_Y1 b
                       WHERE a.EventFunctionalSeq_NUMB = b.EventFunctionalSeq_NUMB)
    GROUP BY EventFunctionalSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (FEDH_DEMO) FEDH_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (FEDH_DEMO) FEDH_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'FEDH_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM FEDH_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM MSSN_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = b.MemberSsn_NUMB)
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = b.MemberSsn_NUMB)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (UNOT_GLEV) UNOT_Y1.EventGlobalApprovalSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (UNOT_GLEV) UNOT_Y1.EventGlobalApprovalSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'UNOT_Y1',
          'EventGlobalApprovalSeq_NUMB',
          a.EventGlobalApprovalSeq_NUMB,
          COUNT (1),
          '4'
     FROM UNOT_Y1 a
    WHERE a.EventGlobalApprovalSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalApprovalSeq_NUMB = b.EventGlobalSeq_NUMB)
    GROUP BY EventGlobalApprovalSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (GLEV_EVMA) GLEV_Y1.EventFunctionalSeq_NUMB NOT IN EVMA_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (GLEV_EVMA) GLEV_Y1.EventFunctionalSeq_NUMB NOT IN EVMA_Y1',
          'FINANCIAL',
          'GLEV_Y1',
          'EventFunctionalSeq_NUMB',
          a.EventFunctionalSeq_NUMB,
          COUNT (1),
          '3'
     FROM GLEV_Y1 a
    WHERE a.EventFunctionalSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM EVMA_Y1 b
                       WHERE a.EventFunctionalSeq_NUMB = b.EventFunctionalSeq_NUMB)
    GROUP BY EventFunctionalSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (IFMS_CMEM) IFMS_Y1 KEY NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (IFMS_CMEM) IFMS_Y1 KEY NOT IN CMEM_Y1',
          'ENFORCEMENT',
          'IFMS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM IFMS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.Case_IDNO = b.Case_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (IFMS_COPT) IFMS_Y1.CountyFips_CODE NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (IFMS_COPT) IFMS_Y1.CountyFips_CODE NOT IN COPT_Y1',
          'ENFORCEMENT',
          'IFMS_Y1',
          'CountyFips_CODE',
          a.CountyFips_CODE,
          COUNT (1),
          '1'
     FROM IFMS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.CountyFips_CODE = b.County_IDNO)
    GROUP BY CountyFips_CODE;

   SET @Ls_Sql_TEXT = 'R.I (IFMS_DEMO) IFMS_Y1 First_NAME,Last_NAME, Middle_NAME,MemberSsn_NUMB not matching with DEMO_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (IFMS_DEMO) IFMS_Y1 First_NAME,Last_NAME, Middle_NAME,MemberSsn_NUMB not matching with DEMO_Y1 table',
          'ENFORCEMENT',
          'IFMS_Y1',
          'MemberMci_IDNO-First_NAME-Last_NAME-Middle_NAME-MemberSsn_NUMB',
          CAST(MemberMci_IDNO AS VARCHAR) + '-' + LTRIM(RTRIM(a.First_NAME)) + '-' + LTRIM(RTRIM(a.Last_NAME)) + '-' + LTRIM(RTRIM(a.Middle_NAME)) + '-' + CAST(a.MemberSsn_NUMB AS VARCHAR),
          COUNT (1),
          '2'
     FROM IFMS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE LTRIM(RTRIM(a.First_NAME)) = LTRIM(RTRIM(b.First_NAME))
                         AND LTRIM(RTRIM(a.Last_NAME)) = LTRIM(RTRIM(b.Last_NAME))
                         AND LTRIM(RTRIM(a.Middle_NAME)) = LTRIM(RTRIM(b.Middle_NAME))
                         AND a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = b.MemberSsn_NUMB)
      AND NOT EXISTS (SELECT 1
                        FROM MSSN_Y1 m
                       WHERE a.MemberMci_IDNO = m.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = m.MemberSsn_NUMB)
    GROUP BY CAST(MemberMci_IDNO AS VARCHAR) + '-' + LTRIM(RTRIM(a.First_NAME)) + '-' + LTRIM(RTRIM(a.Last_NAME)) + '-' + LTRIM(RTRIM(a.Middle_NAME)) + '-' + CAST(a.MemberSsn_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (ISTX_CMEM) ISTX_Y1 KEY NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ISTX_CMEM) ISTX_Y1 KEY NOT IN CMEM_Y1',
          'ENFORCEMENT',
          'ISTX_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM ISTX_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.Case_IDNO = b.Case_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (ISTX_DEMO) ISTX_Y1.MemberSsn_NUMB NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ISTX_DEMO) ISTX_Y1.MemberSsn_NUMB NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'ISTX_Y1',
          'MemberSsn_NUMB',
          a.MemberSsn_NUMB,
          COUNT (1),
          '2'
     FROM ISTX_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM MSSN_Y1 m
                       WHERE a.MemberMci_IDNO = m.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = m.MemberSsn_NUMB)
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberSsn_NUMB = b.MemberSsn_NUMB)
    GROUP BY MemberSsn_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (ICAS_CASE) ICAS_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ICAS_CASE) ICAS_Y1.Case_IDNO NOT IN CASE_Y1',
          'CASE MANAGEMENT',
          'ICAS_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM ICAS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (ICAS_COPT) ICAS_Y1.County_IDNO NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ICAS_COPT) ICAS_Y1.County_IDNO NOT IN COPT_Y1',
          'CASE MANAGEMENT',
          'ICAS_Y1',
          'County_IDNO',
          a.County_IDNO,
          COUNT (1),
          '1'
     FROM ICAS_Y1 a
    WHERE LTRIM(RTRIM (a.County_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.County_IDNO = b.County_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY County_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (ICAS_DCKT) ICAS_Y1.File_ID NOT IN DCKT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ICAS_DCKT) ICAS_Y1.File_ID NOT IN DCKT_Y1',
          'CASE MANAGEMENT',
          'ICAS_Y1',
          'File_ID',
          a.File_ID,
          COUNT (1),
          '1'
     FROM ICAS_Y1 a
    WHERE LTRIM(RTRIM (a.File_ID)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM DCKT_Y1 b
                       WHERE a.File_ID = b.File_ID)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY File_ID;

   SET @Ls_Sql_TEXT = 'R.I (LSTT_DEMO) LSTT_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (LSTT_DEMO) LSTT_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'LSTT_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM LSTT_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DHLD_OBLE) DHLD_Y1 KEY NOT IN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DHLD_OBLE) DHLD_Y1 CASE NOT IN OBLE_Y1',
          'FINANCIAL',
          'DHLD_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OBLE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DHLD_DEMO_FIPS_OTHP) DHLD_Y1.CheckRecipient_ID NOT IN DEMO_Y1,FIPS, OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DHLD_DEMO) DHLD_Y1.CheckRecipient_ID NOT IN DEMO_Y1',
          'FINANCIAL',
          'DHLD_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 c
                       WHERE a.CheckRecipient_ID = c.Fips_CODE
                         AND EndValidity_DATE = '12/31/9999')
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 d
                       WHERE a.CheckRecipient_ID = CAST(d.OtherParty_IDNO AS VARCHAR(9))
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'R.I (DHLD_GLEV) DHLD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DHLD_GLEV) DHLD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'DHLD_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM DHLD_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (DHLD_GLEV) DHLD_Y1.EventGlobalSupportSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DHLD_GLEV) DHLD_Y1.EventGlobalSupportSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'DHLD_Y1',
          'EventGlobalSupportSeq_NUMB',
          a.EventGlobalSupportSeq_NUMB,
          COUNT (1),
          '4'
     FROM DHLD_Y1 a
    WHERE a.EventGlobalSupportSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalSupportSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalSupportSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (LSUP_OBLE) LSUP_Y1 KEY NOT IN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (LSUP_OBLE) LSUP_Y1 KEY NOT IN OBLE_Y1',
          'FINANCIAL',
          'LSUP_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OBLE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (LSUP_RCTH) LSUP_Y1.SourceBatch_CODE NOT IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (LSUP_RCTH) LSUP_Y1.SourceBatch_CODE NOT IN RCTH_Y1',
          'FINANCIAL',
          'LSUP_Y1',
          'SourceBatch_CODE',
          a.SourceBatch_CODE,
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE LTRIM(RTRIM (a.SourceBatch_CODE)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY SourceBatch_CODE;

   SET @Ls_Sql_TEXT = 'R.I (LSUP_OTHP) LSUP_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (LSUP_OTHP) LSUP_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1',
          'FINANCIAL',
          'LSUP_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (DISTINCT a.CheckRecipient_ID),
          '1'
     FROM LSUP_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 c
                       WHERE a.CheckRecipient_ID = c.Fips_CODE
                         AND EndValidity_DATE = '12/31/9999')
      AND (NOT EXISTS (SELECT 1
                         FROM OTHP_Y1 d
                        WHERE a.CheckRecipient_ID = CAST(d.OtherParty_IDNO AS VARCHAR(9))
                          AND EndValidity_DATE = '12/31/9999'))
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'R.I (LSUP_EVMA) LSUP_Y1.EventFunctionalSeq_NUMB NOT IN EVMA_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (LSUP_EVMA) LSUP_Y1.EventFunctionalSeq_NUMB NOT IN EVMA_Y1',
          'FINANCIAL',
          'LSUP_Y1',
          'EventFunctionalSeq_NUMB',
          a.EventFunctionalSeq_NUMB,
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM EVMA_Y1 b
                       WHERE a.EventFunctionalSeq_NUMB = b.EventFunctionalSeq_NUMB)
    GROUP BY EventFunctionalSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (DMJR_SORD) DMJR_Y1 KEY NOT IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DMJR_SORD) DMJR_Y1 KEY NOT IN SORD_Y1',
          'ENFORCEMENT',
          'DMJR_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM DMJR_Y1 a
    WHERE ActivityMajor_CODE IN ('LSNR', 'CRPT', 'CRIM', 'EMNP',
                                 'LIEN', 'LINT', 'OBRA', 'PSOC',
                                 'SEQO', 'CSLN', 'FIDM', 'NMSN',
                                 'IMIW', 'AREN')
      AND Status_CODE != 'EXMT'
      AND NOT EXISTS (SELECT 1
                        FROM SORD_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DMJR_AMJR) DMJR_Y1.ActivityMajor_CODE NOT IN AMJR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DMJR_AMJR) DMJR_Y1.ActivityMajor_CODE NOT IN AMJR_Y1',
          'ENFORCEMENT',
          'DMJR_Y1',
          'ActivityMajor_CODE',
          a.ActivityMajor_CODE,
          COUNT (1),
          '1'
     FROM DMJR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM AMJR_y1 b
                       WHERE a.ActivityMajor_CODE = b.ActivityMajor_CODE)
    GROUP BY ActivityMajor_CODE;

   SET @Ls_Sql_TEXT = 'R.I (DMJR_AMJR) DMJR_Y1.Subsystem_CODE NOT IN AMJR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DMJR_AMJR) DMJR_Y1.Subsystem_CODE NOT IN AMJR_Y1',
          'ENFORCEMENT',
          'DMJR_Y1',
          'Subsystem_CODE',
          a.Subsystem_CODE,
          COUNT (1),
          '1'
     FROM DMJR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM AMJR_y1 b
                       WHERE a.Subsystem_CODE = b.Subsystem_CODE)
    GROUP BY Subsystem_CODE;

   SET @Ls_Sql_TEXT = 'R.I (DMJR_DEMO) DMJR_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (DMJR_DEMO) DMJR_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'DMJR_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (DISTINCT MemberMci_IDNO),
          '1'
     FROM DMJR_Y1 a
    WHERE LTRIM(RTRIM (a.MemberMci_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (DMJR_OTHP) DMJR_Y1.OthpSource_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (DMJR_OTHP) DMJR_Y1.OthpSource_IDNO NOT IN OTHP_Y1',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO',
          a.OthpSource_IDNO,
          COUNT (DISTINCT a.OthpSource_IDNO),
          '1'
     FROM DMJR_Y1 a
    WHERE LTRIM(RTRIM (a.OthpSource_IDNO)) <> 0
      AND (NOT EXISTS (SELECT 1
                         FROM OTHP_Y1 b
                        WHERE a.OthpSource_IDNO = b.OtherParty_IDNO
                          AND EndValidity_DATE = '12/31/9999'))
      AND NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 c
                       WHERE a.OthpSource_IDNO = c.MemberMci_IDNO)
    GROUP BY OthpSource_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (AKAX_DEMO) AKAX_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (AKAX_DEMO) AKAX_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'AKAX_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM AKAX_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BNKR_DEMO) BNKR_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BNKR_DEMO) BNKR_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'BNKR_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM BNKR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BNKR_OTHP) BNKR_Y1.OthpAtty_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BNKR_OTHP) BNKR_Y1.OthpAtty_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'BNKR_Y1',
          'OthpAtty_IDNO',
          a.OthpAtty_IDNO,
          COUNT (1),
          '1'
     FROM BNKR_Y1 a
    WHERE LTRIM(RTRIM (a.OthpAtty_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpAtty_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY OthpAtty_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BNKR_OTHP) BNKR_Y1.OthpBnkrCourt_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BNKR_OTHP) BNKR_Y1.OthpBnkrCourt_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'BNKR_Y1',
          'OthpBnkrCourt_IDNO',
          a.OthpBnkrCourt_IDNO,
          COUNT (1),
          '1'
     FROM BNKR_Y1 a
    WHERE LTRIM(RTRIM (a.OthpBnkrCourt_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpBnkrCourt_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY OthpBnkrCourt_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (BNKR_OTHP) BNKR_Y1.OthpPlanAdmin_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (BNKR_OTHP) BNKR_Y1.OthpPlanAdmin_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'BNKR_Y1',
          'OthpPlanAdmin_IDNO',
          a.OthpPlanAdmin_IDNO,
          COUNT (1),
          '1'
     FROM BNKR_Y1 a
    WHERE LTRIM(RTRIM (a.OthpPlanAdmin_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpPlanAdmin_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY OthpPlanAdmin_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MECN_DEMO) MECN_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MECN_DEMO) MECN_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'MECN_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM MECN_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MDET_DEMO) MDET_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MDET_DEMO) MDET_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'MDET_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MDET_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MINS_DEMO) MINS_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MINS_DEMO) MINS_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'MINS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MINS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MINS_OTHP) MINS_Y1.OthpEmployer_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MINS_OTHP) MINS_Y1.OthpEmployer_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'MINS_Y1',
          'OthpEmployer_IDNO',
          a.OthpEmployer_IDNO,
          COUNT (1),
          '1'
     FROM MINS_Y1 a
    WHERE LTRIM(RTRIM (OthpEmployer_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpEmployer_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY OthpEmployer_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MSSN_DEMO) MSSN_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MSSN_DEMO) MSSN_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'MSSN_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MSSN_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MHIS_CMEM) MHIS_Y1 KEY NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MHIS_CMEM) MHIS_Y1 KEY NOT IN CMEM_Y1',
          'FINANCIAL',
          'MHIS_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.Case_IDNO = b.Case_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (MHIS_GLEV) MHIS_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MHIS_GLEV) MHIS_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'MHIS_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM MHIS_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (DMNR_AMNR) DMNR_Y1.ActivityMinor_CODE NOT IN AMNR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DMNR_AMNR) DMNR_Y1.ActivityMinor_CODE NOT IN AMNR_Y1',
          'ENFORCEMENT',
          'DMNR_Y1',
          'ActivityMinor_CODE',
          a.ActivityMinor_CODE,
          COUNT (1),
          '1'
     FROM DMNR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM AMNR_Y1 b
                       WHERE a.ActivityMinor_CODE = b.ActivityMinor_CODE)
    GROUP BY ActivityMinor_CODE;

   SET @Ls_Sql_TEXT = 'R.I (DMNR_DEMO) DMNR_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (DMNR_DEMO) DMNR_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'DMNR_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (DISTINCT MemberMci_IDNO),
          '1'
     FROM DMNR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (OBLE_SORD) OBLE_Y1 KEY NOT IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OBLE_SORD) OBLE_Y1 KEY NOT IN SORD_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM SORD_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (OBLE_DEBT) OBLE_Y1.TypeDebt_CODE NOT IN DEBT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OBLE_DEBT) OBLE_Y1.TypeDebt_CODE NOT IN DEBT_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'TypeDebt_CODE',
          a.TypeDebt_CODE,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEBT_Y1 b
                       WHERE a.TypeDebt_CODE = b.TypeDebt_CODE)
    GROUP BY TypeDebt_CODE;

   SET @Ls_Sql_TEXT = 'R.I (OBLE_OTHP) OBLE_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (OBLE_OTHP) OBLE_Y1.CheckRecipient_ID NOT IN DEMO_Y1, FIPS_Y1, OTHP_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'CheckRecipient_ID',
          a.CheckRecipient_ID,
          COUNT (DISTINCT a.CheckRecipient_ID),
          '1'
     FROM OBLE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.CheckRecipient_ID = CAST(b.MemberMci_IDNO AS VARCHAR(10)))
      AND NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 c
                       WHERE a.CheckRecipient_ID = c.Fips_CODE
                         AND EndValidity_DATE = '12/31/9999')
      AND (NOT EXISTS (SELECT 1
                         FROM OTHP_Y1 d
                        WHERE a.CheckRecipient_ID = CAST(d.OtherParty_IDNO AS VARCHAR(9))
                          AND EndValidity_DATE = '12/31/9999'))
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'Mismatch Between The Icas Fips Codes And Fips Table Fips Codes';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Mismatch Between The Icas Fips Codes And Fips Table Fips Codes',
          'FINANCIAL',
          'ICAS_Y1',
          'StateFips_CODE-CountyFips_CODE-OfficeFips_CODE',
          IVDOutOfStateFips_CODE + '-' + IVDOutOfStateCountyFips_CODE + '-' + IVDOutOfStateOfficeFips_CODE,
          COUNT (1),
          '1'
     FROM ICAS_Y1 a
    WHERE NOT EXISTS (SELECT *
                        FROM FIPS_Y1
                       WHERE StateFips_CODE = a.IVDOutOfStateFips_CODE
                         AND CountyFips_CODE = a.IVDOutOfStateCountyFips_CODE
                         AND OfficeFips_CODE = a.IVDOutOfStateOfficeFips_CODE
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY IVDOutOfStateFips_CODE,
             IVDOutOfStateCountyFips_CODE,
             IVDOutOfStateOfficeFips_CODE;

   SET @Ls_Sql_TEXT = 'R.I (OBLE_DEMO) OBLE_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OBLE_DEMO) OBLE_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (OBLE_GLEV) OBLE_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OBLE_GLEV) OBLE_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM OBLE_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (ORDB_GLEV) ORDB_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ORDB_GLEV) ORDB_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'ORDB_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM ORDB_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (OTHP_COPT) OTHP_Y1.County_IDNO NOT IN COPT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OTHP_COPT) OTHP_Y1.County_IDNO NOT IN COPT_Y1',
          'MISCELLANEOUS',
          'OTHP_Y1',
          'County_IDNO',
          a.County_IDNO,
          COUNT (1),
          '3'
     FROM OTHP_Y1 a
    WHERE LTRIM(RTRIM (a.County_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM COPT_Y1 b
                       WHERE a.County_IDNO = b.County_IDNO)
    GROUP BY County_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (PLIC_DEMO) PLIC_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (PLIC_DEMO) PLIC_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'CASE MANAGEMENT',
          'PLIC_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM PLIC_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (PLIC_OTHP) PLIC_Y1.OthpLicAgent_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (PLIC_OTHP) PLIC_Y1.OthpLicAgent_IDNO NOT IN OTHP_Y1',
          'CASE MANAGEMENT',
          'PLIC_Y1',
          'OthpLicAgent_IDNO',
          a.OthpLicAgent_IDNO,
          COUNT (1),
          '1'
     FROM PLIC_Y1 a
    WHERE OthpLicAgent_IDNO <> 999999974
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OthpLicAgent_IDNO = b.OtherParty_IDNO
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY OthpLicAgent_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (RCTH_RBAT) RCTH_Y1 KEY NOT IN RBAT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (RCTH_RBAT) RCTH_Y1 KEY NOT IN RBAT_Y1',
          'FINANCIAL',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM RBAT_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'R.I (RCTH_GLEV) RCTH_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (RCTH_GLEV) RCTH_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'RCTH_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM RCTH_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (RBAT_GLEV) RBAT_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (RBAT_GLEV) RBAT_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'RBAT_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM RBAT_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (SLST_DEMO) SLST_Y1.MemberMci_IDNO NOT IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (SLST_DEMO) SLST_Y1.MemberMci_IDNO NOT IN DEMO_Y1',
          'ENFORCEMENT',
          'SLST_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM SLST_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (SORD_CASE) SORD_Y1.Case_IDNO NOT IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (SORD_CASE) SORD_Y1.Case_IDNO NOT IN CASE_Y1',
          'FINANCIAL',
          'SORD_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM SORD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CASE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (SORD_DCKT) SORD_Y1.File_ID NOT IN DCKT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'R.I (SORD_DCKT) SORD_Y1.File_ID NOT IN DCKT_Y1',
          'FINANCIAL',
          'SORD_Y1',
          'File_ID',
          a.File_ID,
          COUNT (DISTINCT File_ID),
          '1'
     FROM SORD_Y1 a
    WHERE LTRIM(RTRIM (File_ID)) <> ''
      AND NOT EXISTS (SELECT 1
                        FROM DCKT_Y1 b
                       WHERE a.File_ID = b.File_ID)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY File_ID;

   SET @Ls_Sql_TEXT = 'R.I (SORD_GLEV) SORD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (SORD_GLEV) SORD_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'SORD_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM SORD_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (TEXC_CMEM) TEXC_Y1.MemberMci_IDNO NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (TEXC_CMEM) TEXC_Y1.MemberMci_IDNO NOT IN CMEM_Y1',
          'ENFORCEMENT',
          'TEXC_Y1',
          'MemberMci_IDNO',
          a.MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM TEXC_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (TEXC_CMEM) TEXC_Y1.Case_IDNO NOT IN VCMEM';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (TEXC_CMEM) TEXC_Y1.Case_IDNO NOT IN CMEM_Y1',
          'ENFORCEMENT',
          'TEXC_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM TEXC_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (URCT_RCTH) URCT_Y1 KEY NOT IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (URCT_RCTH) URCT_Y1 KEY NOT IN RCTH_Y1',
          'FINANCIAL',
          'URCT_Y1',
          'Batch_DATE',
          a.Batch_DATE,
          COUNT (1),
          '1'
     FROM URCT_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_DATE = b.Batch_DATE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND a.SourceReceipt_CODE = b.SourceReceipt_CODE
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY Batch_DATE;

   SET @Ls_Sql_TEXT = 'R.I (URCT_RCTH) URCT_Y1.SourceReceipt_CODE NOT IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (URCT_RCTH) URCT_Y1.SourceReceipt_CODE NOT IN RCTH_Y1',
          'FINANCIAL',
          'URCT_Y1',
          'SourceReceipt_CODE',
          a.SourceReceipt_CODE,
          COUNT (1),
          '1'
     FROM URCT_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.SourceReceipt_CODE = b.SourceReceipt_CODE
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY SourceReceipt_CODE;

   SET @Ls_Sql_TEXT = 'R.I (URCT_OTHP) URCT_Y1.OtherParty_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (URCT_OTHP) URCT_Y1.OtherParty_IDNO NOT IN OTHP_Y1',
          'FINANCIAL',
          'URCT_Y1',
          'OtherParty_IDNO',
          a.OtherParty_IDNO,
          COUNT (1),
          '1'
     FROM URCT_Y1 a
    WHERE LTRIM(RTRIM (a.OtherParty_IDNO)) <> 0
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 b
                       WHERE a.OtherParty_IDNO = b.OtherParty_IDNO)
    GROUP BY OtherParty_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (URCT_GLEV) URCT_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (URCT_GLEV) URCT_Y1.EventGlobalEndSeq_NUMB NOT IN GLEV_Y1',
          'FINANCIAL',
          'URCT_Y1',
          'EventGlobalEndSeq_NUMB',
          a.EventGlobalEndSeq_NUMB,
          COUNT (1),
          '4'
     FROM URCT_Y1 a
    WHERE a.EventGlobalEndSeq_NUMB <> 0
      AND NOT EXISTS (SELECT 1
                        FROM GLEV_Y1 b
                       WHERE a.EventGlobalEndSeq_NUMB = b.EventGlobalSeq_NUMB)
    GROUP BY EventGlobalEndSeq_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (WEMO_IVMG) WEMO_Y1 KEY NOT IN IVMG_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (WEMO_IVMG) WEMO_Y1 KEY NOT IN IVMG_Y1',
          'FINANCIAL',
          'WEMO_Y1',
          'CASE',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM WEMO_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM IVMG_Y1 b
                       WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
                         AND a.WelfareYearMonth_NUMB = b.WelfareYearMonth_NUMB)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (WEMO_OBLE) WEMO_Y1 KEY NOT IN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (WEMO_OBLE) WEMO_Y1 KEY NOT IN OBLE_Y1',
          'FINANCIAL',
          'WEMO_Y1',
          'CASE',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM WEMO_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OBLE_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                         AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS ACTIVE IN MORE THAN ONE TANF CASE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DISTINCT
          'MEMBERS ACTIVE IN MORE THAN ONE TANF CASE',
          'CASE MANAGEMENT',
          'MHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE @Ad_Conversion_DATE BETWEEN a.Start_DATE AND a.End_DATE
      AND a.TypeWelfare_CODE = 'A'
      AND EXISTS (SELECT 1
                    FROM MHIS_Y1 b
                   WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND a.Case_IDNO = b.Case_IDNO
                     AND b.TypeWelfare_CODE = 'A'
                     AND a.CaseWelfare_IDNO != b.CaseWelfare_IDNO
                     AND @Ad_Conversion_DATE BETWEEN b.Start_DATE AND b.End_DATE)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH PRIMARY MemberSsn_NUMB IN MSSN_Y1 NOT FOUND IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH PRIMARY MemberSsn_NUMB IN MSSN_Y1 NOT FOUND IN DEMO_Y1',
          'CASE MANAGEMENT',
          'MSSN_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MSSN_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DEMO_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND a.MemberSsn_NUMB = b.MemberSsn_NUMB)
      AND TypePrimary_CODE = 'P'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'Receipt Posted with PayorMCI_IDNO AND Case_IDNO is <> 0 And StatusReceipt_CODE = U';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Receipt Posted with PayorMCI_IDNO AND Case_IDNO is <> 0 And StatusReceipt_CODE = U',
          'FINANCIAL',
          'RCTH_Y1',
          'PayorMCI_IDNO-Case_IDNO',
          CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1
    WHERE (PayorMCI_IDNO <> 0
           AND Case_IDNO <> 0)
      AND StatusReceipt_CODE = 'U'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'PayorMCI_IDNO IN RCTH_Y1 BUT NOT FOUND IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'PayorMCI_IDNO IN RCTH_Y1 BUT NOT FOUND IN CMEM_Y1',
          'CASE MANAGEMENT',
          'RCTH_Y1',
          'PayorMCI_IDNO',
          PayorMCI_IDNO,
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE a.PayorMCI_IDNO > '0'
      AND NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.PayorMCI_IDNO = b.MemberMci_IDNO)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY PayorMCI_IDNO;

   SET @Ls_Sql_TEXT = 'CS OBLE_Y1 FOR MEMBERS WHO ARE NOT DEPENDANTS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CS OBLE_Y1 FOR MEMBERS WHO ARE NOT DEPENDANTS',
          'FINANCIAL',
          'OBLE_Y1',
          'CASE',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a,
          CMEM_Y1 b
    WHERE a.Case_IDNO = b.Case_IDNO
      AND a.MemberMci_IDNO = b.MemberMci_IDNO
      AND b.CaseRelationship_CODE != 'D'
      AND TypeDebt_CODE = 'CS'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY a.Case_IDNO;

   SET @Ls_Sql_TEXT = 'WELFARE CASE Seq_IDNO POPULATED IN MHIS FOR N TYPE RECORDS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'WELFARE CASE Seq_IDNO POPULATED IN MHIS FOR N TYPE RECORDS',
          'CASE MANAGEMENT',
          'MHIS_Y1',
          'CASE',
          CaseWelfare_IDNO,
          COUNT (1),
          '1'
     FROM MHIS_Y1
    WHERE CaseWelfare_IDNO <> 0
      AND TypeWelfare_CODE = 'N'
    GROUP BY CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'WELFARE CASES ON IVMG WITHOUT ANY PERIODS ON MHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'WELFARE CASES ON IVMG WITHOUT ANY PERIODS ON MHIS',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'CASE',
          CaseWelfare_IDNO,
          COUNT (1),
          '1'
     FROM IVMG_Y1 a
    WHERE (LtdAssistExpend_AMNT > 0
            OR LtdAssistRecoup_AMNT > 0)
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 b
                       WHERE a.CaseWelfare_IDNO = b.CaseWelfare_IDNO
                         AND TypeWelfare_CODE IN ('A', 'F', 'J'))
    GROUP BY CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'CASES IN CASE_Y1 BUT NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES IN CASE_Y1 BUT NOT IN CMEM_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES THAT DO NOT HAVE ORDER BUT HAS ARREARS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES THAT DO NOT HAVE ORDER BUT HAS ARREARS',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM SORD_Y1 b
                       WHERE b.Case_IDNO = a.Case_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND EXISTS (SELECT 1
                    FROM LSUP_Y1 c
                   WHERE c.Case_IDNO = a.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'IRS TAX OFFSET DETAILS BUT NO MATCHING HEADER';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'IRS TAX OFFSET DETAILS BUT NO MATCHING HEADER',
          'CASE MANAGEMENT',
          'FEDH_Y1',
          'MemberMci_IDNO-Case_IDNO',
          CAST(B.MemberMci_IDNO AS VARCHAR) + '-' + CAST(B.ArrearIdentifier_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM FEDH_Y1 B
    WHERE B.ArrearIdentifier_IDNO NOT IN (SELECT DISTINCT
                                                 X.Case_IDNO
                                            FROM IFMS_Y1 X
                                           WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                             AND X.TypeArrear_CODE = B.TypeArrear_CODE
                                             AND X.SubmitLast_DATE = B.SubmitLast_DATE
                                             AND X.TaxYear_NUMB = B.TaxYear_NUMB
                                             AND X.Transaction_AMNT = (SELECT TOP 1 MAX(Y.Transaction_AMNT)
                                                                         FROM IFMS_Y1 Y
                                                                        WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                                          AND Y.TypeArrear_CODE = X.TypeArrear_CODE
                                                                          AND Y.SubmitLast_DATE = X.SubmitLast_DATE
                                                                          AND Y.TaxYear_NUMB = X.TaxYear_NUMB))
    GROUP BY CAST(B.MemberMci_IDNO AS VARCHAR) + '-' + CAST(B.ArrearIdentifier_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'STATE TAX OFFSET DETAILS BUT NO MATCHING HEADER';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'STATE TAX OFFSET DETAILS BUT NO MATCHING HEADER',
          'CASE MANAGEMENT',
          'SLST_Y1',
          'MemberMci_IDNO-Case_IDNO',
          CAST(B.MemberMci_IDNO AS VARCHAR) + '-' + CAST(B.Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM SLST_Y1 B
    WHERE B.Case_IDNO NOT IN (SELECT DISTINCT
                                     X.Case_IDNO
                                FROM ISTX_Y1 X
                               WHERE X.MemberMci_IDNO = B.MemberMci_IDNO
                                 AND X.TypeArrear_CODE = B.TypeArrear_CODE
                                 AND X.SubmitLast_DATE = B.SubmitLast_DATE
                                 AND X.TaxYear_NUMB = B.TaxYear_NUMB
                                 AND X.Transaction_AMNT = (SELECT TOP 1 MAX(Y.Transaction_AMNT)
                                                             FROM ISTX_Y1 Y
                                                            WHERE Y.MemberMci_IDNO = X.MemberMci_IDNO
                                                              AND Y.TypeArrear_CODE = X.TypeArrear_CODE
                                                              AND Y.SubmitLast_DATE = X.SubmitLast_DATE
                                                              AND Y.TaxYear_NUMB = X.TaxYear_NUMB))
    GROUP BY CAST(B.MemberMci_IDNO AS VARCHAR) + '-' + CAST(B.Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'CASES WITH NO NCP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH NO NCP',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CMEM_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND b.CaseRelationship_CODE IN ('A', 'P'))
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH NO MHIS RECORD';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH NO MHIS RECORD',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE StatusCase_CODE = 'O'
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 b
                       WHERE b.Case_IDNO = a.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH NON CONTIGUOUS MHIS DATES';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH NON CONTIGUOUS MHIS DATES',
          'FINANCIAL',
          'MHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE a.End_DATE != '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND b.Start_DATE = DATEADD(D, 1, a.End_DATE))
      AND EXISTS (SELECT 1
                    FROM MHIS_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND b.Start_DATE > a.End_DATE)
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'TANF MHIS RECORD END DATE SHOULD HAVE ONLY MONTH END DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TANF MHIS RECORD END DATE SHOULD HAVE ONLY MONTH END DATE' AS Reason,
          'CASE MANAGEMENT' AS SubSystem,
          'MHIS_Y1',
          'Case_IDNO-MemberMci_IDNO-End_DATE',
          CAST(Case_IDNO AS VARCHAR) + '-' + CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(End_DATE AS VARCHAR),
          COUNT(1),
          '1'
     FROM MHIS_Y1
    WHERE TypeWelfare_CODE = 'A'
      AND End_DATE <> '12/31/9999'
      AND End_DATE <> CONVERT(VARCHAR(25), DATEADD(dd, -(DAY(DATEADD(mm, 1, End_DATE))), DATEADD(mm, 1, End_DATE)), 101)
    GROUP BY Case_IDNO,
             MemberMci_IDNO,
             End_DATE;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH OVERLAPPING MHIS DATES';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH OVERLAPPING MHIS DATES',
          'FINANCIAL',
          'MHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM MHIS_Y1 b
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND a.MemberMci_IDNO = b.MemberMci_IDNO
                     AND a.Start_DATE != b.Start_DATE
                     AND ((a.Start_DATE BETWEEN b.Start_DATE AND b.End_DATE)
                           OR (a.End_DATE BETWEEN b.Start_DATE AND b.End_DATE)))
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH MULTIPLE MAILING ADDRESS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH MULTIPLE MAILING ADDRESS',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM (SELECT MemberMci_IDNO,
                  TypeAddress_CODE,
                  COUNT (1) AS a
             FROM AHIS_Y1
            WHERE End_DATE = '12/31/9999'
              AND Status_CODE = 'Y'
            GROUP BY MemberMci_IDNO,
                     TypeAddress_CODE
           HAVING COUNT (1) > 1) AS b
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'CP WITH VERIFIED ADDRESS BUT NO Status_CODE LOCATED IN LSTT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CP WITH VERIFIED ADDRESS BUT NO Status_CODE LOCATED IN LSTT_Y1',
          'CASE MANAGEMENT',
          'LSTT_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM (SELECT DISTINCT
                  a.MemberMci_IDNO
             FROM AHIS_Y1 a,
                  CMEM_Y1 b
            WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
              AND a.TypeAddress_CODE = 'M'
              AND b.CaseRelationship_CODE = 'C'
              AND a.Status_CODE = 'Y'
              AND a.End_DATE = '12/31/9999'
              AND NOT EXISTS (SELECT 1
                                FROM LSTT_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.StatusLocate_CODE = 'L'
                                 AND EndValidity_DATE = '12/31/9999')
              AND NOT EXISTS (SELECT 1
                                FROM DHLD_Y1 d
                               WHERE d.CheckRecipient_ID = a.MemberMci_IDNO
                                 AND d.ReasonStatus_CODE = 'SDCA'
                                 AND EndValidity_DATE = '12/31/9999')) AS a
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'NCP WITH VERIFIED ADDRESS/EMPLOYER BUT NO Status_CODE LOCATED IN LSTT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NCP WITH VERIFIED ADDRESS/EMPLOYER BUT NO Status_CODE LOCATED IN LSTT_Y1',
          'CASE MANAGEMENT',
          'LSTT_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM (SELECT DISTINCT
                  a.MemberMci_IDNO
             FROM AHIS_Y1 a,
                  CMEM_Y1 b
            WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
              AND a.TypeAddress_CODE = 'M'
              AND b.CaseRelationship_CODE IN ('A', 'P')
              AND a.Status_CODE = 'Y'
              AND a.End_DATE = '12/31/9999'
              AND NOT EXISTS (SELECT 1
                                FROM LSTT_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.StatusLocate_CODE = 'L'
                                 AND EndValidity_DATE = '12/31/9999')
              AND NOT EXISTS (SELECT 1
                                FROM CMEM_Y1 d
                               WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND d.CaseRelationship_CODE = 'C')
           UNION
           SELECT DISTINCT
                  a.MemberMci_IDNO
             FROM EHIS_Y1 a,
                  CMEM_Y1 b
            WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
              AND b.CaseRelationship_CODE IN ('A', 'P')
              AND a.Status_CODE = 'Y'
              AND TypeIncome_CODE != 'UA'
              AND a.EndEmployment_DATE = '12/31/9999'
              AND NOT EXISTS (SELECT 1
                                FROM LSTT_Y1 c
                               WHERE c.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND c.StatusLocate_CODE = 'L'
                                 AND EndValidity_DATE = '12/31/9999')
              AND NOT EXISTS (SELECT 1
                                FROM CMEM_Y1 d
                               WHERE d.MemberMci_IDNO = a.MemberMci_IDNO
                                 AND d.CaseRelationship_CODE = 'C')) AS a
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'TANF WELFARE TYPE ON LSUP MISMATCH WITH MHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TANF WELFARE TYPE ON LSUP MISMATCH WITH MHIS',
          'FINANCIAL',
          'LSUP_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a,
          OBLE_Y1 b,
          CASE_Y1 c
    WHERE a.TypeWelfare_CODE = 'A'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
      AND b.TypeDebt_CODE IN ('CS', 'MS', 'SS')
      AND c.Case_IDNO = b.Case_IDNO
      AND c.StatusCase_CODE = 'O'
      AND NOT EXISTS (SELECT *
                        FROM MHIS_Y1
                       WHERE MHIS_Y1.Case_IDNO = a.Case_IDNO
                         AND MHIS_Y1.MemberMci_IDNO = b.MemberMci_IDNO
                         AND MHIS_Y1.TypeWelfare_CODE = 'A'
                         AND @Ad_Conversion_DATE BETWEEN Start_DATE AND End_DATE)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'N-TANF WELFARE TYPE ON LSUP MISMATCH WITH MHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'N-TANF WELFARE TYPE ON LSUP MISMATCH WITH MHIS',
          'FINANCIAL',
          'LSUP_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a,
          OBLE_Y1 b
    WHERE a.TypeWelfare_CODE = 'N'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
      AND b.TypeDebt_CODE IN ('CS', 'MS', 'SS')
      AND NOT EXISTS (SELECT *
                        FROM MHIS_Y1 c
                       WHERE c.Case_IDNO = a.Case_IDNO
                         AND c.MemberMci_IDNO = b.MemberMci_IDNO
                         AND c.TypeWelfare_CODE = 'N'
                         AND @Ad_Conversion_DATE BETWEEN c.Start_DATE AND c.End_DATE)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'FOSTER CARE WELFARE TYPE ON LSUP MISMATCH WITH MHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'FOSTER CARE WELFARE TYPE ON LSUP MISMATCH WITH MHIS',
          'FINANCIAL',
          'LSUP_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a,
          OBLE_Y1 b,
          CASE_Y1 c
    WHERE a.TypeWelfare_CODE = 'F'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
      AND b.TypeDebt_CODE IN ('CS', 'MS', 'SS')
      AND c.Case_IDNO = b.Case_IDNO
      AND c.StatusCase_CODE = 'O'
      AND NOT EXISTS (SELECT *
                        FROM MHIS_Y1
                       WHERE MHIS_Y1.Case_IDNO = a.Case_IDNO
                         AND MHIS_Y1.MemberMci_IDNO = b.MemberMci_IDNO
                         AND MHIS_Y1.TypeWelfare_CODE = 'F'
                         AND @Ad_Conversion_DATE BETWEEN Start_DATE AND End_DATE)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'NON-IVD WELFARE TYPE ON LSUP MISMATCH WITH MHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NON-IVD WELFARE TYPE ON LSUP MISMATCH WITH MHIS',
          'FINANCIAL',
          'LSUP_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a,
          OBLE_Y1 b,
          CASE_Y1 c
    WHERE a.TypeWelfare_CODE = 'H'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
      AND b.TypeDebt_CODE IN ('CS', 'MS', 'SS')
      AND c.Case_IDNO = b.Case_IDNO
      AND c.StatusCase_CODE = 'O'
      AND NOT EXISTS (SELECT *
                        FROM MHIS_Y1
                       WHERE MHIS_Y1.Case_IDNO = a.Case_IDNO
                         AND MHIS_Y1.MemberMci_IDNO = b.MemberMci_IDNO
                         AND MHIS_Y1.TypeWelfare_CODE = 'H'
                         AND @Ad_Conversion_DATE BETWEEN Start_DATE AND End_DATE)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'CLOSED CASES WITH OPEN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CLOSED CASES WITH OPEN OBLE_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a
    WHERE a.FreqPeriodic_CODE <> 'O'
      AND a.Periodic_AMNT = 0
      AND a.EndObligation_DATE > @Ad_Conversion_DATE
      AND a.EndValidity_DATE = '12/31/9999'
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 c
                   WHERE a.Case_IDNO = c.Case_IDNO
                     AND StatusCase_CODE = 'C')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'OBLE_Y1 - OBLE_Y1 WITH PER AMT AND NO ACCRUAL DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'OBLE_Y1 - OBLE_Y1 WITH PER AMT AND NO ACCRUAL DATE',
          'FINANCIAL',
          'OBLE_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1 a,
          CASE_Y1 c
    WHERE EndObligation_DATE > @Ad_Conversion_DATE
      AND AccrualNext_DATE = '12/31/9999'
      AND Periodic_AMNT > 0
      AND EndValidity_DATE = '12/31/9999'
      AND FreqPeriodic_CODE <> 'O'
      AND a.Case_IDNO = c.Case_IDNO
      AND c.StatusCase_CODE = 'O'
    GROUP BY a.Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeCase_CODE IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeCase_CODE IN CASE_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1
    WHERE TypeCase_CODE NOT IN (SELECT LTRIM (RTRIM(Value_CODE))
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'CCRT'
                                   AND TableSub_ID = 'CTYP')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID StatusCase_CODE IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID StatusCase_CODE IN CASE_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1
    WHERE StatusCase_CODE NOT IN (SELECT Value_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'CSTS'
                                     AND TableSub_ID = 'CSTS')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID CaseCategory_CODE IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID CaseCategory_CODE IN CASE_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '2'
     FROM CASE_Y1
    WHERE CaseCategory_CODE NOT IN (SELECT Value_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'CCRT'
                                       AND TableSub_ID = 'CCTG')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID GoodCause_CODE IN VACSE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID GoodCause_CODE IN VACSE',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '3'
     FROM CASE_Y1
    WHERE LTRIM (RTRIM(GoodCause_CODE)) <> ''
      AND GoodCause_CODE NOT IN (SELECT Value_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'CCRT'
                                    AND TableSub_ID = 'NCOP')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID ServiceRequested_CODE IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID ServiceRequested_CODE IN CASE_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '3'
     FROM CASE_Y1
    WHERE ServiceRequested_CODE NOT IN (SELECT Value_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'CCRT'
                                           AND TableSub_ID = 'SREQ')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID CaseRelationship_CODE IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID CaseRelationship_CODE IN CMEM_Y1',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CMEM_Y1
    WHERE CaseRelationship_CODE NOT IN (SELECT Value_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'RELA'
                                           AND TableSub_ID = 'CASE')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID CaseMemberStatus_CODE IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID CaseMemberStatus_CODE IN CMEM_Y1',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CMEM_Y1
    WHERE CaseMemberStatus_CODE NOT IN (SELECT Value_CODE
                                          FROM REFM_Y1
                                         WHERE Table_ID = 'GENR'
                                           AND TableSub_ID = 'MEMS')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID CpRelationshipToChild_CODE IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID CpRelationshipToChild_CODE IN CMEM_Y1',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '2'
     FROM CMEM_Y1
    WHERE LTRIM (RTRIM(CpRelationshipToChild_CODE)) <> ''
      AND CpRelationshipToChild_CODE NOT IN (SELECT Value_CODE
                                               FROM REFM_Y1
                                              WHERE Table_ID = 'FMLY'
                                                AND TableSub_ID = 'RELA')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeAlias_CODE IN AKAX_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeAlias_CODE IN AKAX_Y1',
          'CASE MANAGEMENT',
          'AKAX_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM AKAX_Y1
    WHERE TypeAlias_CODE NOT IN (SELECT Value_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'DEMO'
                                    AND TableSub_ID = 'ALAS')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypePrimary_CODE IN MSSN_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypePrimary_CODE IN MSSN_Y1',
          'CASE MANAGEMENT',
          'MSSN_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM MSSN_Y1
    WHERE TypePrimary_CODE NOT IN (SELECT LTRIM (RTRIM(Value_CODE))
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'DEMO'
                                      AND TableSub_ID = 'SSNT')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeAddress_CODE IN AHIS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeAddress_CODE IN AHIS_Y1',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE NOT IN (SELECT Value_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'ADDR'
                                      AND TableSub_ID = 'ADD1')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID FreqPay_CODE IN EHIS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID FreqPay_CODE IN EHIS_Y1',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM EHIS_Y1
    WHERE LTRIM (RTRIM(FreqPay_CODE)) <> ''
      AND FreqPay_CODE NOT IN (SELECT Value_CODE
                                 FROM REFM_Y1
                                WHERE Table_ID = 'FRQA'
                                  AND TableSub_ID = 'FRQ1')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID CD_ FREQ_INSURANCE IN EHIS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID CD_ FREQ_INSURANCE IN EHIS_Y1',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM EHIS_Y1
    WHERE LTRIM (RTRIM(FreqInsurance_CODE)) <> ''
      AND FreqInsurance_CODE NOT IN (SELECT Value_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'FRQA'
                                        AND TableSub_ID = 'FRQ4')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID StatusLocate_CODE IN LSTT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID StatusLocate_CODE IN LSTT_Y1',
          'CASE MANAGEMENT',
          'LSTT_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM LSTT_Y1
    WHERE StatusLocate_CODE NOT IN (SELECT Value_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'LOCS'
                                       AND TableSub_ID = 'LOCS')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeTransaction_CODE IN FEDH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeTransaction_CODE IN FEDH_Y1',
          'CASE MANAGEMENT',
          'FEDH_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM FEDH_Y1
    WHERE TypeTransaction_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'TAXI'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeTransaction_CODE IN SLST_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeTransaction_CODE IN SLST_Y1',
          'CASE MANAGEMENT',
          'SLST_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SLST_Y1
    WHERE TypeTransaction_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'STXH'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeArrear_CODE IN FEDH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeArrear_CODE IN FEDH_Y1',
          'CASE MANAGEMENT',
          'FEDH_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '1'
     FROM FEDH_Y1
    WHERE TypeArrear_CODE NOT IN (SELECT Value_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'ARTP')
    GROUP BY MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeArrear_CODE IN SLST_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeArrear_CODE IN SLST_Y1',
          'CASE MANAGEMENT',
          'SLST_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SLST_Y1
    WHERE TypeArrear_CODE NOT IN (SELECT Value_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'TAXI'
                                     AND TableSub_ID = 'ARTP')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeDebt_CODE IN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeDebt_CODE IN OBLE_Y1',
          'CASE MANAGEMENT',
          'OBLE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1
    WHERE TypeDebt_CODE NOT IN (SELECT Value_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DBTP'
                                   AND TableSub_ID = 'DBTP')
    GROUP BY Case_IDNO

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeDebt_CODE IN ORDB_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeDebt_CODE IN ORDB_Y1',
          'CASE MANAGEMENT',
          'ORDB_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM ORDB_Y1
    WHERE TypeDebt_CODE NOT IN (SELECT Value_CODE
                                  FROM REFM_Y1
                                 WHERE Table_ID = 'DBTP'
                                   AND TableSub_ID = 'DBTP')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID FreqPeriodic_CODE IN OBLE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID FreqPeriodic_CODE IN OBLE_Y1',
          'CASE MANAGEMENT',
          'OBLE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM OBLE_Y1
    WHERE FreqPeriodic_CODE NOT IN (SELECT Value_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'FRQA'
                                       AND TableSub_ID = 'FRQ3')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID RsnStatusCase_CODE IN VACSE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID RsnStatusCase_CODE IN VACSE',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1
    WHERE LTRIM (RTRIM(RsnStatusCase_CODE)) <> ''
      AND RsnStatusCase_CODE NOT IN (SELECT Value_CODE
                                       FROM REFM_Y1
                                      WHERE Table_ID = 'CCRT'
                                        AND TableSub_ID = 'CCLO')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID RespondInit_CODE IN CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID RespondInit_CODE IN CASE_Y1',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1
    WHERE LTRIM(RTRIM (RespondInit_CODE)) <> ''
      AND RespondInit_CODE NOT IN (SELECT Value_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'INTS'
                                      AND TableSub_ID = 'CATG')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID Race_CODE IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID Race_CODE IN DEMO_Y1',
          'CASE MANAGEMENT',
          'DEMO_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM DEMO_Y1
    WHERE Race_CODE NOT IN (SELECT Value_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'GENR'
                               AND TableSub_ID = 'RACE')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID ColorHair_CODE IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID ColorHair_CODE IN DEMO_Y1',
          'CASE MANAGEMENT',
          'DEMO_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM (ColorHair_CODE)) <> ''
      AND ColorHair_CODE NOT IN (SELECT Value_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'DEMO'
                                    AND TableSub_ID = 'HAIR')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID ColorEyes_CODE IN DEMO_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID ColorEyes_CODE IN DEMO_Y1',
          'CASE MANAGEMENT',
          'DEMO_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM DEMO_Y1
    WHERE LTRIM(RTRIM (ColorEyes_CODE)) <> ''
      AND ColorEyes_CODE NOT IN (SELECT Value_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'DEMO'
                                    AND TableSub_ID = 'EYEC')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeBankruptcy_CODE IN BNKR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeBankruptcy_CODE IN BNKR_Y1',
          'CASE MANAGEMENT',
          'BNKR_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM BNKR_Y1
    WHERE LTRIM(RTRIM (TypeBankruptcy_CODE)) <> ''
      AND EndValidity_DATE = '12/31/9999'
      AND TypeBankruptcy_CODE NOT IN (SELECT Value_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'DEMO'
                                         AND TableSub_ID = 'BANK')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID Status_CODE IN AHIS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID Status_CODE IN AHIS_Y1',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE Status_CODE NOT IN (SELECT Value_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'CONF'
                                 AND TableSub_ID = 'CON1')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID Status_CODE IN EHIS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID Status_CODE IN EHIS_Y1',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MemberMci_IDNO',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM EHIS_Y1
    WHERE Status_CODE NOT IN (SELECT Value_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'CONF'
                                 AND TableSub_ID = 'CON1')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID TypeLicence_CODE IN PLIC_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID TypeLicence_CODE IN PLIC_Y1',
          'CASE MANAGEMENT',
          'PLIC_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM PLIC_Y1
    WHERE TypeLicense_CODE NOT IN (SELECT Value_CODE
                                     FROM REFM_Y1
                                    WHERE Table_ID = 'LICT'
                                      AND TableSub_ID = 'TYPE')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID Status_CODE IN PLIC_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBERS WITH INVALID Status_CODE IN PLIC_Y1',
          'CASE MANAGEMENT',
          'PLIC_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM PLIC_Y1
    WHERE Status_CODE NOT IN (SELECT Value_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'MLIC'
                                 AND TableSub_ID = 'VERI')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID InsOrdered_CODE IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID InsOrdered_CODE IN SORD_Y1',
          'FINANCIAL',
          'SORD_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SORD_Y1
    WHERE InsOrdered_CODE NOT IN (SELECT Value_CODE
                                    FROM REFM_Y1
                                   WHERE Table_ID = 'SORD'
                                     AND TableSub_ID = 'INSO')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID Iiwo_CODE IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID Iiwo_CODE IN SORD_Y1',
          'CASE MANAGEMENT',
          'SORD_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SORD_Y1
    WHERE Iiwo_CODE NOT IN (SELECT Value_CODE
                              FROM REFM_Y1
                             WHERE Table_ID = 'SORD'
                               AND TableSub_ID = 'IWOR')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID CoverageMedical_CODE IN SORD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID CoverageMedical_CODE IN SORD_Y1',
          'CASE MANAGEMENT',
          'SORD_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '3'
     FROM SORD_Y1
    WHERE CoverageMedical_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'SORD'
                                          AND TableSub_ID = 'INSO')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CHECK_RECIPIENT WITH INVALID CheckRecipient_CODE IN EFTR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CHECK_RECIPIENT WITH INVALID CheckRecipient_CODE IN EFTR_Y1',
          'CASE MANAGEMENT',
          'EFTR_Y1',
          'CHECK_RECIPIENT',
          CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM EFTR_Y1
    WHERE CheckRecipient_CODE NOT IN (SELECT Value_CODE
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'GENR'
                                         AND TableSub_ID = 'FUND')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'CHECK_RECIPIENT WITH INVALID StatusEft_CODE IN EFTR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CHECK_RECIPIENT WITH INVALID StatusEft_CODE IN EFTR_Y1',
          'CASE MANAGEMENT',
          'EFTR_Y1',
          'CHECK_RECIPIENT',
          CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM EFTR_Y1
    WHERE StatusEft_CODE NOT IN (SELECT Value_CODE
                                   FROM REFM_Y1
                                  WHERE Table_ID = 'EFTR'
                                    AND TableSub_ID = 'EFTS')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'CHECK_RECIPIENT WITH INVALID Status_CODE IN DCRS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CHECK_RECIPIENT WITH INVALID Status_CODE IN DCRS_Y1',
          'CASE MANAGEMENT',
          'DCRS_Y1',
          'CHECK_RECIPIENT',
          CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM DCRS_Y1
    WHERE Status_CODE NOT IN (SELECT Value_CODE
                                FROM REFM_Y1
                               WHERE Table_ID = 'DCST'
                                 AND TableSub_ID = 'DCST')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeTransaction_CODE IN IFMS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeTransaction_CODE IN IFMS_Y1',
          'CASE MANAGEMENT',
          'IFMS_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '2'
     FROM IFMS_Y1
    WHERE TypeTransaction_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'TAXI'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID TypeTransaction_CODE IN ISTX_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID TypeTransaction_CODE IN ISTX_Y1',
          'CASE MANAGEMENT',
          'ISTX_Y1',
          'CASE',
          Case_IDNO,
          COUNT (1),
          '2'
     FROM ISTX_Y1
    WHERE TypeTransaction_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'STXH'
                                          AND TableSub_ID = 'TRAN')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MEMBERS WITH INVALID MSSN_Y1.SourceVerify_CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT ' MEMBERS WITH INVALID MSSN_Y1.SourceVerify_CODE',
          'CASE MANAGEMENT',
          'MSSN_Y1',
          'MemberMci_IDNO',
          MemberMci_IDNO,
          COUNT (1),
          '3'
     FROM MSSN_Y1
    WHERE SourceVerify_CODE NOT IN (SELECT Value_CODE
                                      FROM REFM_Y1
                                     WHERE Table_ID = 'DEMO'
                                       AND TableSub_ID = 'VERS')
      AND RTRIM(LTRIM (SourceVerify_CODE)) <> ''
    GROUP BY MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'CURRENT TANF CASE TYPE MISMATCH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CURRENT TANF CASE TYPE MISMATCH',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE TypeCase_CODE = 'N'
      AND EXISTS (SELECT 1
                    FROM MHIS_Y1 b,
                         CMEM_Y1 c
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND b.End_DATE > @Ad_Conversion_DATE
                     AND b.TypeWelfare_CODE IN ('A', 'F', 'J')
                     AND b.Case_IDNO = c.Case_IDNO
                     AND b.MemberMci_IDNO = c.MemberMci_IDNO
                     AND c.CaseRelationship_CODE = 'D')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'NON-IVD CASE TYPE MISMATCH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NON-IVD CASE TYPE MISMATCH',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE TypeCase_CODE = 'H'
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 b,
                             CMEM_Y1 c
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND b.End_DATE > @Ad_Conversion_DATE
                         AND b.TypeWelfare_CODE = 'H'
                         AND b.Case_IDNO = c.Case_IDNO
                         AND b.MemberMci_IDNO = c.MemberMci_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASE HAVING MORE THAN ONE ACTIVE ORDER';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE HAVING MORE THAN ONE ACTIVE ORDER',
          'CASE MANAGEMENT',
          'SORD_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SORD_Y1 a
    WHERE EndValidity_DATE = '12/31/9999'
    GROUP BY Case_IDNO
   HAVING COUNT(1) > 1;

   SET @Ls_Sql_TEXT = 'LSUP - NEGATIVE AMOUNT VALUE IN LSUP APPL/OWED BUCKET';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - NEGATIVE AMOUNT VALUE IN LSUP APPL/OWED BUCKET',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM (SELECT 'TransactionCurSup_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionCurSup_AMNT < 0
           UNION ALL
           SELECT 'OweTotCurSup_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotCurSup_AMNT < 0
           UNION ALL
           SELECT 'AppTotCurSup_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotCurSup_AMNT < 0
           UNION ALL
           SELECT 'MtdCurSupOwed_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE MtdCurSupOwed_AMNT < 0
           UNION ALL
           SELECT 'TransactionExptPay_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionExptPay_AMNT < 0
           UNION ALL
           SELECT 'OweTotExptPay_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotExptPay_AMNT < 0
           UNION ALL
           SELECT 'AppTotExptPay_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotExptPay_AMNT < 0
           UNION ALL
           SELECT 'TransactionNaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNaa_AMNT < 0
           UNION ALL
           SELECT 'OweTotNaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotNaa_AMNT < 0
           UNION ALL
           SELECT 'AppTotNaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotNaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionPaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionPaa_AMNT < 0
           UNION ALL
           SELECT 'OweTotPaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotPaa_AMNT < 0
           UNION ALL
           SELECT 'AppTotPaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotPaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionTaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionTaa_AMNT < 0
           UNION ALL
           SELECT 'OweTotTaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotTaa_AMNT < 0
           UNION ALL
           SELECT 'AppTotTaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotTaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionCaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionCaa_AMNT < 0
           UNION ALL
           SELECT 'OweTotCaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotCaa_AMNT < 0
           UNION ALL
           SELECT 'AppTotCaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotCaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionUpa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUpa_AMNT < 0
           UNION ALL
           SELECT 'OweTotUpa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotUpa_AMNT < 0
           UNION ALL
           SELECT 'AppTotUpa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotUpa_AMNT < 0
           UNION ALL
           SELECT 'TransactionUda_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUda_AMNT < 0
           UNION ALL
           SELECT 'OweTotUda_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotUda_AMNT < 0
           UNION ALL
           SELECT 'AppTotUda_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotUda_AMNT < 0
           UNION ALL
           SELECT 'TransactionIvef_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionIvef_AMNT < 0
           UNION ALL
           SELECT 'OweTotIvef_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotIvef_AMNT < 0
           UNION ALL
           SELECT 'AppTotIvef_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotIvef_AMNT < 0
           UNION ALL
           SELECT 'TransactionMedi_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionMedi_AMNT < 0
           UNION ALL
           SELECT 'OweTotMedi_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotMedi_AMNT < 0
           UNION ALL
           SELECT 'AppTotMedi_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotMedi_AMNT < 0
           UNION ALL
           SELECT 'TransactionNffc_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNffc_AMNT < 0
           UNION ALL
           SELECT 'OweTotNffc_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotNffc_AMNT < 0
           UNION ALL
           SELECT 'AppTotNffc_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotNffc_AMNT < 0
           UNION ALL
           SELECT 'TransactionNonIvd_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNonIvd_AMNT < 0
           UNION ALL
           SELECT 'OweTotNonIvd_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE OweTotNonIvd_AMNT < 0
           UNION ALL
           SELECT 'AppTotNonIvd_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotNonIvd_AMNT < 0
           UNION ALL
           SELECT 'TransactionFuture_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionFuture_AMNT < 0
           UNION ALL
           SELECT 'AppTotFuture_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE AppTotFuture_AMNT < 0) A
    GROUP BY Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'LSUP - TRANSACTION BUCKET HAS POSITIVE AMOUNT VALUE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - TRANSACTION BUCKET HAS POSITIVE AMOUNT VALUE',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM (SELECT 'TransactionExptPay_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionExptPay_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionNaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNaa_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionPaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionPaa_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionTaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionTaa_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionCaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionCaa_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionUpa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUpa_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionUda_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUda_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionIvef_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionIvef_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionMedi_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionMedi_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionNffc_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNffc_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionNonIvd_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNonIvd_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)
           UNION ALL
           SELECT 'TransactionFuture_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionFuture_AMNT > 0
              AND EventFunctionalSeq_NUMB NOT IN (1820, 1030)) A
    GROUP BY Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'LSUP - TRANSACTION BUCKET HAS NEGATIVE AMOUNT VALUE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - TRANSACTION BUCKET HAS NEGATIVE AMOUNT VALUE',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM (SELECT 'TransactionExptPay_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionExptPay_AMNT < 0
           UNION ALL
           SELECT 'TransactionNaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionPaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionPaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionTaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionTaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionCaa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionCaa_AMNT < 0
           UNION ALL
           SELECT 'TransactionUpa_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUpa_AMNT < 0
           UNION ALL
           SELECT 'TransactionUda_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionUda_AMNT < 0
           UNION ALL
           SELECT 'TransactionIvef_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionIvef_AMNT < 0
           UNION ALL
           SELECT 'TransactionMedi_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionMedi_AMNT < 0
           UNION ALL
           SELECT 'TransactionNffc_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNffc_AMNT < 0
           UNION ALL
           SELECT 'TransactionNonIvd_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionNonIvd_AMNT < 0
           UNION ALL
           SELECT 'TransactionFuture_AMNT' Source,
                  *
             FROM LSUP_Y1
            WHERE TransactionFuture_AMNT < 0) A
    GROUP BY Source + ' - ' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Receipt Posted with PayorMCI_IDNO AND Case_IDNO is 0 And StatusReceipt_CODE <> U';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Receipt Posted with PayorMCI_IDNO AND Case_IDNO is 0 And StatusReceipt_CODE <> U',
          'FINANCIAL',
          'RCTH_Y1',
          'PayorMCI_IDNO-Case_IDNO',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1
    WHERE PayorMCI_IDNO = '0'
      AND StatusReceipt_CODE <> 'U'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Receipt Posted with PayorMCI_IDNO <> 0 or Case_IDNO <> 0 And StatusReceipt_CODE = U'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Receipt Posted with PayorMCI_IDNO <> 0 or Case_IDNO <> 0 And StatusReceipt_CODE = U',
          'FINANCIAL',
          'RCTH_Y1',
          'PayorMCI_IDNO-Case_IDNO',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1
    WHERE (PayorMCI_IDNO <> '0'
            OR Case_IDNO <> '0')
      AND StatusReceipt_CODE = 'U'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + CAST(PayorMCI_IDNO AS VARCHAR) + '-' + CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'CASES WITH INVALID RefundRecipient_CODE IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASES WITH INVALID RefundRecipient_CODE IN RCTH_Y1',
          'CASE MANAGEMENT',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM RCTH_Y1
    WHERE LTRIM (RTRIM(RefundRecipient_CODE)) <> ''
      AND RefundRecipient_CODE NOT IN (SELECT Value_CODE
                                         FROM REFM_Y1
                                        WHERE Table_ID = 'RERT'
                                          AND TableSub_ID IN ('IDEN', 'UNID'))
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'LSUP - CS OWED AMOUNT VALUE IS LESS THAN CS APPLIED AMOUNT VALUE AND SUM OF CS OWED, CS APPL AMOUNT VALUE IS EQUAL TO MTD CS OWED AMOUNT VALUE.';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - CS OWED AMOUNT VALUE IS LESS THAN CS APPLIED AMOUNT VALUE AND SUM OF CS OWED, CS APPL AMOUNT VALUE IS EQUAL TO MTD CS OWED AMOUNT VALUE.',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE MtdCurSupOwed_AMNT > 0
      AND OweTotCurSup_AMNT + AppTotCurSup_AMNT = MtdCurSupOwed_AMNT
      AND AppTotCurSup_AMNT > 0
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'LSUP - CS OWED AMOUNT VALUE IS LESS THAN CS APPLIED AMOUNT VALUE AND MTD CS OWED AMOUNT VALUE IS EQUAL TO ZERO'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - CS OWED AMOUNT VALUE IS LESS THAN CS APPLIED AMOUNT VALUE AND MTD CS OWED AMOUNT VALUE IS EQUAL TO ZERO',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE MtdCurSupOwed_AMNT = 0
      AND OweTotCurSup_AMNT > 0
      AND OweTotCurSup_AMNT < AppTotCurSup_AMNT
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'LSUP - GT - GENETIC TEST DEBT TYPE WHICH HAS OWED AMOUNT VALUE OTHER THAN NAA BUCKET'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - GT - GENETIC TEST DEBT TYPE WHICH HAS OWED AMOUNT VALUE OTHER THAN NAA BUCKET',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM OBLE_Y1 a,
          LSUP_Y1 b
    WHERE a.TypeDebt_CODE = 'GT'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
      AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
      AND (OweTotPaa_AMNT > 0
            OR OweTotTaa_AMNT > 0
            OR OweTotCaa_AMNT > 0
            OR OweTotUpa_AMNT > 0
            OR OweTotUda_AMNT > 0
            OR OweTotIvef_AMNT > 0
            OR OweTotNffc_AMNT > 0
            OR OweTotMedi_AMNT > 0
            OR OweTotNonIvd_AMNT > 0)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'LSUP - CS OWED AMOUNT VALUE IS GREATER THAN MTD CS OWED AMOUNT VALUE($0) WHEN ACTIVE OBLIGATION EXISTS'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - CS OWED AMOUNT VALUE IS GREATER THAN MTD CS OWED AMOUNT VALUE($0) WHEN ACTIVE OBLIGATION EXISTS',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE OweTotCurSup_AMNT - AppTotCurSup_AMNT <> MtdCurSupOwed_AMNT
      AND EXISTS(SELECT 1
                   FROM OBLE_Y1 b
                  WHERE a.Case_IDNO = b.Case_IDNO
                    AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
                    AND a.ObligationSeq_NUMB = b.ObligationSeq_NUMB
                    AND b.EndObligation_DATE >= @Ad_Conversion_DATE
                    AND b.EndValidity_DATE = '12/31/9999')
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'LSUP - MORE THAN ONE RECORD EXISTS IN LSUP FOR CASE Seq_IDNO, Seq_IDNO ORDER AND Seq_IDNO OBLE_Y1 COMBINATION'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP - MORE THAN ONE RECORD EXISTS IN LSUP FOR CASE Seq_IDNO, Seq_IDNO ORDER AND Seq_IDNO OBLE_Y1 COMBINATION',
          'FINANCIAL',
          'LSUP_Y1',
          'Column_Source-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE EventFunctionalSeq_NUMB NOT IN (1820, 1030)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR)
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'R.I (OBLE) Invalid(Past) AccrualNext_DATE IN OBLE_Y1'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (OBLE) Invalid(Past) AccrualNext_DATE IN OBLE_Y1',
          'FINANCIAL',
          'OBLE_Y1',
          'Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM OBLE_Y1 a
    WHERE EndValidity_DATE = '12/31/9999'
      AND AccrualNext_DATE < @Ad_Conversion_DATE
      AND EndObligation_DATE >= @Ad_Conversion_DATE
      AND Periodic_AMNT > 0.00
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(a.ObligationSeq_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'RBAT - MORE THAN ONE RECORD EXISTS IN RBAT FOR Batch_DATE, SourceBatch_CODE AND Batch_NUMB COMBINATION'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RBAT - MORE THAN ONE RECORD EXISTS IN RBAT FOR Batch_DATE, SourceBatch_CODE AND Batch_NUMB COMBINATION',
          'FINANCIAL',
          'RBAT_Y1',
          'Column_Source-Batch_DATE-SourceBatch_CODE-Batch_NUMB',
          CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM RBAT_Y1 a
    WHERE EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR)
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'R.I (ASFN_OTHP) ASFN_Y1.OthpInsFin_IDNO(INSURANCE-1) NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ASFN_OTHP) ASFN_Y1.OthpInsFin_IDNO(INSURANCE-1) NOT IN OTHP_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'ASFN_Y1' AS Table_NAME,
          'OthpInsFin_IDNO' AS EntityType_TEXT,
          a.OthpInsFin_IDNO AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM ASFN_Y1 A
    WHERE Asset_CODE = 'INS'
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 O
                       WHERE O.OtherParty_IDNO = A.OthpInsFin_IDNO
                         AND o.TypeOthp_CODE = 'I')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY a.OthpInsFin_IDNO

   SET @Ls_Sql_TEXT = 'R.I (ASFN_OTHP) ASFN_Y1.OthpInsFin_IDNO(INSURANCE-2) NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ASFN_OTHP) ASFN_Y1.OthpInsFin_IDNO(INSURANCE-2) NOT IN OTHP_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'ASFN_Y1' AS Table_NAME,
          'OthpInsFin_IDNO' AS EntityType_TEXT,
          a.OthpInsFin_IDNO AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM ASFN_Y1 A
    WHERE Asset_CODE <> 'INS'
      AND EXISTS (SELECT 1
                    FROM OTHP_Y1 O
                   WHERE O.OtherParty_IDNO = A.OthpInsFin_IDNO
                     AND o.TypeOthp_CODE = 'I')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY a.OthpInsFin_IDNO

   SET @Ls_Sql_TEXT = 'R.I (RBAT_RCTH) RBAT_Y1 ControlReceipt_AMNT AND ActualReceipt_AMNT NOT MACHING IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (RBAT_RCTH) RBAT_Y1 ControlReceipt_AMNT AND ActualReceipt_AMNT NOT MACHING IN RCTH_Y1' AS DescriptionError_TEXT,
          'FINANCIAL' AS FunctionalArea_TEXT,
          'RBAT_Y1' AS Table_NAME,
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB' AS EntityType_TEXT,
          CONVERT(VARCHAR, b.Batch_DATE, 112) + '-' + CAST(b.SourceBatch_CODE AS VARCHAR) + '-' + CAST(b.Batch_NUMB AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '1' AS ErrorCount_QNTY
     FROM RBAT_Y1 b
          JOIN (SELECT A.Batch_DATE,
                       A.SourceBatch_CODE,
                       A.Batch_NUMB,
                       A.ControlReceipt_AMNT,
                       A.ActualReceipt_AMNT,
                       A.RcthActualReceipt_AMNT
                  FROM (SELECT B.Batch_DATE,
                               B.SourceBatch_CODE,
                               B.Batch_NUMB,
                               B.ControlReceipt_AMNT,
                               B.ActualReceipt_AMNT,
                               SUM(R.ToDistribute_AMNT) AS RcthActualReceipt_AMNT
                          FROM (SELECT a.Batch_DATE,
                                       a.SourceBatch_CODE,
                                       a.Batch_NUMB,
                                       SUM(ABS(a.ToDistribute_AMNT)) AS ToDistribute_AMNT
                                  FROM RCTH_Y1 a
                                       JOIN GLEV_Y1 c
                                        ON a.EventGlobalBeginSeq_NUMB = c.EventGlobalSeq_NUMB
                                 WHERE a.EndValidity_DATE = '12/31/9999'
                                   AND a.EventGlobalBeginSeq_NUMB = (SELECT MAX(d.EventGlobalBeginSeq_NUMB)
                                                                       FROM RCTH_Y1 d
                                                                      WHERE d.Batch_NUMB = a.Batch_NUMB
                                                                        AND d.Batch_DATE = a.Batch_DATE
                                                                        AND d.SeqReceipt_NUMB = a.SeqReceipt_NUMB
                                                                        AND d.SourceBatch_CODE = a.SourceBatch_CODE
                                                                        AND d.EndValidity_DATE = '12/31/9999')
                                 GROUP BY a.Batch_DATE,
                                          a.SourceBatch_CODE,
                                          a.Batch_NUMB) R
                               JOIN RBAT_Y1 B
                                ON R.Batch_DATE = B.Batch_DATE
                                   AND R.SourceBatch_CODE = B.SourceBatch_CODE
                                   AND R.Batch_NUMB = B.Batch_NUMB
                         WHERE B.StatusBatch_CODE = 'R'
                               --AND  R.EndValidity_DATE   = '12/31/9999'     
                               AND B.EndValidity_DATE = '12/31/9999'
                         GROUP BY B.Batch_DATE,
                                  B.SourceBatch_CODE,
                                  B.Batch_NUMB,
                                  B.ControlReceipt_AMNT,
                                  B.ActualReceipt_AMNT) A
                 WHERE A.RcthActualReceipt_AMNT != A.ActualReceipt_AMNT) r
           ON R.Batch_DATE = B.Batch_DATE
              AND R.SourceBatch_CODE = B.SourceBatch_CODE
              AND R.Batch_NUMB = B.Batch_NUMB
    WHERE B.StatusBatch_CODE = 'R'
      AND b.ControlReceipt_AMNT != R.RcthActualReceipt_AMNT
      AND b.ActualReceipt_AMNT != R.RcthActualReceipt_AMNT
    GROUP BY CONVERT(VARCHAR, b.Batch_DATE, 112) + '-' + CAST(b.SourceBatch_CODE AS VARCHAR) + '-' + CAST(b.Batch_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (DPRS_CMEM_Y1) DPRS_Y1 MEMBER NOT IN CMEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DPRS_CMEM_Y1) DPRS_Y1 MEMBER NOT IN CMEM_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'DPRS_Y1' AS Table_NAME,
          'File_ID-DocketPerson_IDNO' AS EntityType_TEXT,
          CAST(d.File_ID AS VARCHAR) + '-' + CAST(d.DocketPerson_IDNO AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM DPRS_Y1 d
    WHERE d.TypePerson_CODE IN ('NCP', 'CP', 'CI', 'GC')
      AND NOT EXISTS (SELECT 1
                        FROM CASE_Y1 ca
                             JOIN CMEM_Y1 cm
                              ON cm.Case_IDNO = ca.Case_IDNO
                             JOIN FDEM_y1 fm
                              ON fm.Case_IDNO = ca.Case_IDNO
                       WHERE d.DocketPerson_IDNO = cm.MemberMci_IDNO
                         AND fm.File_ID = d.File_ID
                         AND cm.MemberMci_IDNO = d.DocketPerson_IDNO)
    GROUP BY CAST(d.File_ID AS VARCHAR) + '-' + CAST(d.DocketPerson_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (DPRS_CMEM_Y1) DPRS_Y1 ATTORNEY NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DPRS_CMEM_Y1) DPRS_Y1 ATTORNEY NOT IN OTHP_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'DPRS_Y1' AS Table_NAME,
          'File_ID-DocketPerson_IDNO' AS EntityType_TEXT,
          CAST(d.File_ID AS VARCHAR) + '-' + CAST(d.DocketPerson_IDNO AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '3' AS ErrorCount_QNTY
     FROM DPRS_Y1 d
    WHERE d.TypePerson_CODE IN ('RA', 'PA')
      AND NOT EXISTS (SELECT 1
                        FROM CASE_Y1 ca,
                             OTHP_Y1 ot
                       WHERE ca.File_ID = d.File_ID
                         AND ot.OtherParty_IDNO = d.DocketPerson_IDNO
                         AND ot.TypeOthp_CODE = 'A')
    GROUP BY CAST(d.File_ID AS VARCHAR) + '-' + CAST(d.DocketPerson_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (EHIS_OTHP EHIS_Y1 EMPLOYER NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EHIS_OTHP EHIS_Y1 EMPLOYER NOT IN OTHP_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'EHIS_Y1' AS Table_NAME,
          'MemberMci_IDNO-OthpPartyEmpl_IDNO' AS EntityType_TEXT,
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.OthpPartyEmpl_IDNO AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '1' AS ErrorCount_QNTY
     FROM EHIS_Y1 A
    WHERE NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 O
                       WHERE O.OTHERPARTY_IDNO = A.OTHPPARTYEMPL_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND @Ad_Conversion_DATE BETWEEN A.BEGINEMPLOYMENT_DATE AND A.ENDEMPLOYMENT_DATE
    GROUP BY CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.OthpPartyEmpl_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I (MINS_OTHP) MINS_Y1.OthpInsurance_IDNO NOT IN OTHP_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MINS_OTHP) MINS_Y1.OthpInsurance_IDNO NOT IN OTHP_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'MINS_Y1' AS Table_NAME,
          'OthpInsurance_IDNO' AS EntityType_TEXT,
          a.OthpInsurance_IDNO AS ENTITY_ID,
          COUNT (1),
          '1' AS ErrorCount_QNTY
     FROM MINS_Y1 A
    WHERE NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 O
                       WHERE O.OtherParty_IDNO = A.OthpInsurance_IDNO
                         AND o.TypeOthp_CODE = 'I'
                         AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY a.OthpInsurance_IDNO

   SET @Ls_Sql_TEXT = 'ASFN - MORE THAN ONE RECORD EXISTS IN ASFN FOR MemberMci_IDNO,OthpInsFin_IDNO AND AccountAssetNo_TEXT COMBINATION';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ASFN - MORE THAN ONE RECORD EXISTS IN ASFN FOR MemberMci_IDNO,OthpInsFin_IDNO AND AccountAssetNo_TEXT COMBINATION',
          'ENFORCEMENT',
          'ASFN_Y1',
          'Column_Source-MemberMci_IDNO-OthpInsFin_IDNO-AccountAssetNo_TEXT',
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.OthpInsFin_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.AccountAssetNo_TEXT)) AS VARCHAR),
          COUNT (1),
          '2'
     FROM ASFN_Y1 a
    WHERE EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.OthpInsFin_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.AccountAssetNo_TEXT)) AS VARCHAR)
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'EHIS_Y1 - SourceLoc_CODE LWD IS NOT VALID CODE AND IT HAS TO BE CHANGED TO DOL CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'EHIS_Y1 - SourceLoc_CODE LWD IS NOT VALID CODE AND IT HAS TO BE CHANGED TO DOL CODE',
          'FINANCIAL',
          'EHIS_Y1',
          'SourceLoc_CODE',
          a.SourceLoc_CODE,
          COUNT (1),
          '3'
     FROM EHIS_Y1 a
    WHERE SourceLoc_CODE = 'LWD'
    GROUP BY SourceLoc_CODE;

   SET @Ls_Sql_TEXT = 'R.I (DMNR_DMJR) DMNR_Y1 KEY NOT IN DMJR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (DMNR_DMJR) DMNR_Y1 KEY NOT IN DMJR_Y1',
          'ENFORCEMENT',
          'DMNR_Y1',
          'Column_Source-Case_IDNO-Orderseq_NUMB-MajorIntSeq_NUMB',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.ORDERSEQ_NUMB AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.MAJORINTSEQ_NUMB)) AS VARCHAR),
          COUNT (1),
          '1'
     FROM DMNR_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND a.ORDERSEQ_NUMB = b.ORDERSEQ_NUMB
                         AND a.MAJORINTSEQ_NUMB = b.MAJORINTSEQ_NUMB)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.ORDERSEQ_NUMB AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.MAJORINTSEQ_NUMB)) AS VARCHAR)
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'RCTH - Receipt_DATE is converted with Low Date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTH - Receipt_DATE is converted with Low Date',
          'FINANCIAL',
          'RCTH_Y1',
          'Receipt_DATE',
          a.Receipt_DATE,
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE Receipt_DATE = '01/01/0001'
    GROUP BY Receipt_DATE;

   SET @Ls_Sql_TEXT = 'RCTH_LSUP - Receipts Distributed Without Batch Reconciled'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTH_LSUP - Receipts Distributed Without Batch Reconciled',
          'FINANCIAL',
          'RCTH_Y1',
          'Column_Source-Batch_DATE-SourceBatch_CODE-Batch_NUMB',
          CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE A.EndValidity_DATE = '9999/12/31'
      AND Distribute_DATE <> '01/01/0001'
      AND NOT EXISTS (SELECT 1
                        FROM rbat_Y1 B
                       WHERE A.batch_date = B.Batch_DATE
                         AND A.SourceBatch_CODE = B.SourceBatch_CODE
                         AND A.Batch_NUMB = B.Batch_NUMB
                         AND B.EndValidity_DATE = '9999/12/31'
                         AND B.StatusBatch_CODE = 'R')
    GROUP BY CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'RCTH_LSUP - Unrelated RCTH Payor ID AND LSUP Case ID'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTH_LSUP - Unrelated RCTH Payor ID AND LSUP Case ID',
          'FINANCIAL',
          'RCTH_Y1-LSUP_Y1',
          'Column_Source-RCTH_PayorMci_IDNO-RCTH_Case_IDNO-LSUP_Case_IDNO-Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CAST(a.PayorMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(b.Case_IDNO AS VARCHAR) + '-' + CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1 a,
          LSUP_Y1 b
    WHERE A.EndValidity_DATE = '9999/12/31'
      AND A.Distribute_DATE <> '01/01/0001'
      AND A.batch_date = B.Batch_DATE
      AND A.SourceBatch_CODE = B.SourceBatch_CODE
      AND A.Batch_NUMB = B.Batch_NUMB
      AND A.SeqReceipt_NUMB = B.SeqReceipt_NUMB
      AND B.Case_IDNO NOT IN (SELECT Case_IDNO
                                FROM CMEM_Y1 C
                               WHERE A.PayorMci_IDNO = C.MemberMci_IDNO)
    GROUP BY CAST(a.PayorMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(b.Case_IDNO AS VARCHAR) + '-' + CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'RCTH - Invalid Reversal Reason'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTH - Invalid Reversal Reason',
          'FINANCIAL',
          'RCTH_Y1',
          'Column_Source-ReasonBackOut_CODE-Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          ReasonBackOut_CODE + '-' + CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE Backout_INDC = 'Y'
      AND EndValidity_DATE = '12/31/9999'
      AND ReasonBackOut_CODE NOT IN (SELECT Value_CODE
                                       FROM refm_Y1
                                      WHERE Table_ID = 'RREP'
                                        AND TableSub_ID = 'REVR')
    GROUP BY ReasonBackOut_CODE + '-' + CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR)

   SET @Ls_Sql_TEXT = 'RCTH - Receipt_AMNT is not matching with SUM(ToDistribute_AMNT)'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTH - Receipt_AMNT is not matching with SUM(ToDistribute_AMNT)',
          'FINANCIAL',
          'RCTH_Y1',
          'Column_Source-Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-Receipt_AMNT-Sum_ToDistribute_AMNT',
          CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR) + '-' + CAST(Receipt_AMNT AS VARCHAR) + '-' + CAST(Sum_ToDistribute_AMNT AS VARCHAR),
          COUNT (1),
          '1'
     FROM (SELECT Batch_DATE,
                  SourceBatch_CODE,
                  Batch_NUMB,
                  SeqReceipt_NUMB,
                  Receipt_AMNT,
                  SUM(ToDistribute_AMNT) Sum_ToDistribute_AMNT
             FROM rcth_Y1
            WHERE EndValidity_DATE = '12/31/9999'
            GROUP BY Batch_DATE,
                     SourceBatch_CODE,
                     Batch_NUMB,
                     SeqReceipt_NUMB,
                     Receipt_AMNT) A
    WHERE A.Receipt_AMNT != A.Sum_ToDistribute_AMNT
    GROUP BY CAST(a.Batch_DATE AS VARCHAR) + '-' + CAST(a.SourceBatch_CODE AS VARCHAR) + '-' + CAST(a.Batch_NUMB AS VARCHAR) + '-' + CAST(a.SeqReceipt_NUMB AS VARCHAR) + '-' + CAST(Receipt_AMNT AS VARCHAR) + '-' + CAST(Sum_ToDistribute_AMNT AS VARCHAR)

   SET @Ls_Sql_TEXT = 'MEMBER WITH INVALID SourceVerified_CODE IN MDIN_Y1'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MEMBER WITH INVALID SourceVerified_CODE IN MDIN_Y1',
          'CASE MANAGEMENT',
          'MINS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM MINS_Y1
    WHERE SourceVerified_CODE NOT IN (SELECT LTRIM (RTRIM(Value_CODE))
                                        FROM REFM_Y1
                                       WHERE Table_ID = 'MDIN'
                                         AND TableSub_ID = 'SRCE')
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (PLIC) PLIC_Y1.OthpLicAgent_IDNO(OTHER PARTY TYPE) DUPLICATE IN PLIC_Y1'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (PLIC) PLIC_Y1.OthpLicAgent_IDNO(OTHER PARTY TYPE) DUPLICATE IN PLIC_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'PLIC_Y1' AS Table_NAME,
          'MemberMci_IDNO-TypeLicense_CODE-OthpLicAgent_IDNO-LicenseNo_TEXT' AS EntityType_TEXT,
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.TypeLicense_CODE AS VARCHAR) + '-' + CAST(a.OthpLicAgent_IDNO AS VARCHAR) + '-' + LicenseNo_TEXT AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM PLIC_Y1 A
    WHERE EndValidity_DATE = '9999-12-31'
      AND Status_CODE = 'CG'
      AND LicenseStatus_CODE = 'A'
      AND @Ad_Conversion_DATE BETWEEN IssueLicense_DATE AND ExpireLicense_DATE
    GROUP BY MemberMci_IDNO,
             TypeLicense_CODE,
             OthpLicAgent_IDNO,
             LicenseNo_TEXT
   HAVING COUNT(1) > 1;

   SET @Ls_Sql_TEXT = 'R.I (EHIS) EHIS_Y1.OthpPartyEmpl_IDNO(OTHER PARTY IDNO) DUPLICATE IN EHIS_Y1)'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (EHIS) EHIS_Y1.OthpPartyEmpl_IDNO(OTHER PARTY IDNO) DUPLICATE IN EHIS_Y1' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'EHIS_Y1' AS Table_NAME,
          'MemberMci_IDNO OthpPartyEmpl_IDNO' AS EntityType_TEXT,
          CAST(a.MemberMci_IDNO AS VARCHAR) + ' ' + CAST(a.OthpPartyEmpl_IDNO AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM EHIS_Y1 A
    WHERE a.Status_CODE = 'Y'
      AND @Ad_Conversion_DATE BETWEEN a.BeginEmployment_DATE AND a.EndEmployment_DATE
    GROUP BY MemberMci_IDNO,
             OthpPartyEmpl_IDNO
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'CASE - Cases that do not have a File Number or a Petition Number, but yet have support orders AND obligations';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE - Cases that do not have a File Number or a Petition Number, but yet have support orders AND obligations',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE_ID',
          Case_IDNO,
          COUNT(1),
          '1'
     FROM CASE_Y1 a
    WHERE StatusCase_CODE = 'O'
      AND File_ID = ''
      AND EXISTS (SELECT *
                    FROM SORD_Y1
                   WHERE Case_IDNO = a.Case_IDNO)
      AND EXISTS (SELECT *
                    FROM oble_Y1
                   WHERE Case_IDNO = a.Case_IDNO)
      AND NOT EXISTS (SELECT *
                        FROM FDEM_Y1
                       WHERE Case_IDNO = a.Case_IDNO)
    GROUP BY Case_IDNO

   SET @Ls_Sql_TEXT = 'OTHP_Y1.OtherParty_NAME is starts with Space';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'OTHP_Y1.OtherParty_NAME is starts with Space',
          'ENFORCEMENT',
          'OTHP',
          'OtherParty_IDNO-OtherParty_NAME',
          CAST(OtherParty_IDNO AS VARCHAR) + '-' + OtherParty_NAME AS ENTITY_ID,
          COUNT(1),
          '3'
     FROM othp_Y1
    WHERE OtherParty_NAME LIKE ' %'
      AND EndValidity_DATE = '12/31/9999'
      AND WorkerUpdate_ID = 'CONVERSION'
    GROUP BY CAST(OtherParty_IDNO AS VARCHAR) + '-' + OtherParty_NAME

   SET @Ls_Sql_TEXT = 'SORD Direct Pay Indicator is set to Y for cases which are not a Non IV-D cases';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'SORD Direct Pay Indicator is set to Y for cases which are not a Non IV-D cases',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          CAST(c.Case_IDNO AS VARCHAR),
          COUNT(1),
          '2'
     FROM CASE_Y1 c,
          SORD_Y1 s
    WHERE c.Case_IDNO = s.Case_IDNO
      AND TypeCase_CODE <> 'H'
      AND DirectPay_INDC = 'Y'
    GROUP BY CAST(c.Case_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Non IV-D Cases with no dependents';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Non IV-D Cases with no dependents',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          CAST(Case_IDNO AS VARCHAR),
          COUNT(1),
          '2'
     FROM CASE_Y1 a
    WHERE StatusCase_CODE = 'O'
      AND typecase_code = 'H'
      AND NOT EXISTS (SELECT 1
                        FROM cmem_Y1
                       WHERE Case_IDNO = a.Case_IDNO
                         AND CaseRelationship_CODE = 'D')
    GROUP BY CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Incorrect last review AND next review dates in SORD.Last review dates & next review date in conversion are more than 3 years in the past';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Sord Last Review Date should be LOWDATE(01/01/0001)',
          'CASE MANAGEMENT',
          'SORD_Y1-CASE_Y1-OBLE_Y1',
          'Case_IDNO-orderent_date-orderissued_date-ordereffective_date,lastreview_date-nextreview_date-beginobligation_date-periodic_amnt',
          (CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.orderent_date AS VARCHAR) + '-' + CAST(a.orderissued_date AS VARCHAR) + '-' + CAST(a.ordereffective_date AS VARCHAR) + '-' + CAST(a.orderend_date AS VARCHAR) + '-' + CAST(a.lastreview_date AS VARCHAR) + '-' + CAST(a.nextreview_date AS VARCHAR) + '-' + CAST(c.beginobligation_date AS VARCHAR) + '-' + CAST(c.periodic_amnt AS VARCHAR) + '-' + CAST(c.endobligation_date AS VARCHAR)),
          COUNT(1),
          '2'
     FROM SORD_Y1 a,
          CASE_Y1 b,
          oble_Y1 c
    WHERE a.Case_IDNO = b.Case_IDNO
      AND b.Case_IDNO = c.Case_IDNO
      AND b.StatusCase_CODE = 'O'
      AND b.typecase_code <> 'H'
      AND typedebt_code = 'CS'
      AND periodic_amnt > 0
      AND endobligation_date >= '10/01/2015'
      AND a.orderend_date >= '10/01/2015'
      AND lastreview_date <> '01/01/0001'
    GROUP BY (CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.orderent_date AS VARCHAR) + '-' + CAST(a.orderissued_date AS VARCHAR) + '-' + CAST(a.ordereffective_date AS VARCHAR) + '-' + CAST(a.orderend_date AS VARCHAR) + '-' + CAST(a.lastreview_date AS VARCHAR) + '-' + CAST(a.nextreview_date AS VARCHAR) + '-' + CAST(c.beginobligation_date AS VARCHAR) + '-' + CAST(c.periodic_amnt AS VARCHAR) + '-' + CAST(c.endobligation_date AS VARCHAR));

   SET @Ls_Sql_TEXT = 'SORD_Y1.StatusOrder_CODE should be space';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'SORD_Y1.StatusOrder_CODE should be space',
          'CASE MANAGEMENT',
          'SORD_Y1',
          'Case_IDNO',
          CAST(Case_IDNO AS VARCHAR),
          COUNT(1),
          '3'
     FROM SORD_Y1
    WHERE EndValidity_DATE = '12/31/9999'
      AND LTRIM(RTRIM(StatusOrder_CODE)) <> ''
    GROUP BY CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Collections Only non IV-D cases must have an obligation record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Collections Only non IV-D cases must have an obligation record',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          CAST(Case_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM CASE_Y1 b
    WHERE b.StatusCase_CODE = 'O'
      AND typecase_code = 'H'
      AND casecategory_code <> 'DP'
      AND File_ID <> ' '
      AND EXISTS (SELECT *
                    FROM SORD_Y1
                   WHERE Case_IDNO = b.Case_IDNO
                     AND orderend_date > '10/01/2013')
      AND NOT EXISTS (SELECT *
                        FROM oble_Y1
                       WHERE Case_IDNO = b.Case_IDNO)
    GROUP BY CAST(Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Disbursement Without Misc_ID (Control Number)';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disbursement Without Misc_ID (Control Number)',
          'FINANCIAL',
          'DSBH_Y1',
          'Case_IDNO-orderent_date-orderissued_date-ordereffective_date,lastreview_date-nextreview_date-beginobligation_date-periodic_amnt',
          (CAST(LTRIM(RTRIM(a.CheckRecipient_ID)) AS VARCHAR) + '-' + CAST(a.CheckRecipient_CODE AS VARCHAR) + '-' + CAST(a.Disburse_DATE AS VARCHAR) + '-' + CAST(a.DisburseSeq_NUMB AS VARCHAR)),
          COUNT(1),
          '1'
     FROM dsbh_Y1 a
    WHERE (LTRIM(RTRIM(Misc_ID)) = ''
            OR LTRIM(RTRIM(Misc_ID)) = '0')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY (CAST(LTRIM(RTRIM(a.CheckRecipient_ID)) AS VARCHAR) + '-' + CAST(a.CheckRecipient_CODE AS VARCHAR) + '-' + CAST(a.Disburse_DATE AS VARCHAR) + '-' + CAST(a.DisburseSeq_NUMB AS VARCHAR));

   SET @Ls_Sql_TEXT = 'MHIS - TANF Case with CaseWelfare_IDNO = 0';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MHIS - TANF Case with CaseWelfare_IDNO = 0',
          'CASE MANAGEMENT',
          'MHIS_Y1',
          'Case_IDNO-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE TypeWelfare_CODE IN ('A')
      AND CaseWelfare_IDNO = 0
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'MHIS - FosterCare Case with CaseWelfare_IDNO = 0';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MHIS - FosterCare Case with CaseWelfare_IDNO = 0',
          'CASE MANAGEMENT',
          'MHIS_Y1',
          'Case_IDNO-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM MHIS_Y1 a
    WHERE TypeWelfare_CODE IN ('F')
      AND CaseWelfare_IDNO = 0
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'IVMG records with CpMci_IDNO = 0';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'IVMG records with CpMci_IDNO = 0',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'CaseWelfare_IDNO',
          CAST(CaseWelfare_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM IVMG_Y1 a
    WHERE CpMci_IDNO = 0
    GROUP BY CAST(CaseWelfare_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Invalid CpMci_IDNO in IVMG.CpMci_IDNO is not converted as CP in CMEM';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid CpMci_IDNO in IVMG.CpMci_IDNO is not converted as CP in CMEM',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'CaseWelfare_IDNO-CpMci_IDNO',
          CAST(CaseWelfare_IDNO AS VARCHAR) + '-' + CAST(a.CpMci_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM IVMG_Y1 A
    WHERE WelfareElig_CODE = 'A'
      AND CpMci_IDNO <> 0
      AND EXISTS (SELECT 1
                    FROM MHIS_Y1 B
                   WHERE A.CpMci_IDNO = B.MemberMci_IDNO
                     AND TypeWelfare_CODE = 'A'
                     AND A.CaseWelfare_IDNO = B.CaseWelfare_IDNO)
      AND EXISTS (SELECT 1
                    FROM CMEM_Y1 B
                   WHERE A.CpMci_IDNO = B.MemberMci_IDNO)
      AND NOT EXISTS (SELECT 1
                        FROM CMEM_Y1 B
                       WHERE A.CpMci_IDNO = B.MemberMci_IDNO
                         AND CaseRelationship_CODE = 'C')
    GROUP BY CAST(CaseWelfare_IDNO AS VARCHAR) + '-' + CAST(a.CpMci_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'BeginEmployment_DATE SHOULD NOT BE HIGH DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'BeginEmployment_DATE SHOULD NOT BE HIGH DATE',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'BeginEmployment_DATE',
          BeginEmployment_DATE,
          COUNT (1),
          '2'
     FROM EHIS_Y1 a
    WHERE BeginEmployment_DATE = '12/31/9999'
    GROUP BY BeginEmployment_DATE

   SET @Ls_Sql_TEXT = 'Activity chains CANNOT be associated with inactive members';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ESTP AND MAPP activity chains CANNOT be associated with inactive members',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO',
          OthpSource_IDNO,
          COUNT (1),
          '1'
     FROM dmjr_Y1 a
    WHERE Status_CODE = 'STRT'
      AND OthpSource_IDNO IN (SELECT MemberMci_IDNO
                                FROM cmem_Y1 b
                               WHERE a.Case_IDNO = b.Case_IDNO
                                 AND CaseMemberStatus_CODE = 'I')
    GROUP BY OthpSource_IDNO

   SET @Ls_Sql_TEXT = 'ESTP activity chain CANNOT be associated with a OTHER PARTY. The source should always be a case member';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ESTP activity chain CANNOT be associated with a OTHER PARTY. The source should always be a case member',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO',
          OthpSource_IDNO,
          COUNT (1),
          '1'
     FROM dmjr_Y1
    WHERE ActivityMajor_CODE IN ('ESTP')
      AND TypeOthpSource_CODE NOT IN ('A', 'P')
    GROUP BY OthpSource_IDNO

   SET @Ls_Sql_TEXT = 'Any major activity associated to a OTHER PARTY must have the same OTHP Type as the DMJR record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Any major activity associated to a OTHER PARTY must have the same OTHP Type as the DMJR record',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO-TypeOthp_code-TypeOthpSource_code',
          CAST(OthpSource_IDNO AS VARCHAR) + '-' + o.TypeOthp_code + '-' + j.TypeOthpSource_code,
          COUNT (1),
          '1'
     FROM dmjr_Y1 j,
          othp_Y1 o
    WHERE o.Otherparty_IDNO = j.OthpSource_IDNO
      AND o.TypeOthp_code != j.TypeOthpSource_code
      AND LEN(OthpSource_IDNO) = 9
      AND TypeOthpSource_CODE NOT IN ('A', 'P')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(OthpSource_IDNO AS VARCHAR) + '-' + o.TypeOthp_code + '-' + j.TypeOthpSource_code

   SET @Ls_Sql_TEXT = 'ActivityMajor_code must match DMNR AND DMJR tables';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ActivityMajor_code must match DMNR AND DMJR tables',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO-TypeOthp_code-TypeOthpSource_code',
          CAST(OthpSource_IDNO AS VARCHAR) + '-' + d.ActivityMajor_code + '-' + j.ActivityMajor_code,
          COUNT (1),
          '1'
     FROM dmnr_Y1 d,
          dmjr_Y1 j
    WHERE d.Case_IDNO = j.Case_IDNO
      AND d.MajorIntSeq_NUMB = j.MajorIntSeq_NUMB
      AND j.ActivityMajor_code != d.ActivityMajor_code
    GROUP BY CAST(OthpSource_IDNO AS VARCHAR) + '-' + d.ActivityMajor_code + '-' + j.ActivityMajor_code

   SET @Ls_Sql_TEXT = 'INTERSTATE CASE NOT IN ICAS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'INTERSTATE CASE NOT IN ICAS_Y1',
          'CASE INITIATION',
          'ICAS_Y1',
          'Case_IDNO',
          CAST(a.Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE a.RespondInit_CODE IN ('I', 'R')
      AND NOT EXISTS(SELECT 1
                       FROM ICAS_Y1 b
                      WHERE b.Case_IDNO = a.Case_IDNO)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'DISB Refund DHLD_Y1.CheckRecipient_ID AND DHLD_Y1.CheckRecipient_CODE should EXISTS in Pseduo refund receipt RCTH_Y1.RefundRecipient_ID, RCTH_Y1.RefundRecipient_CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DISB Refund DHLD_Y1.CheckRecipient_ID AND DHLD_Y1.CheckRecipient_CODE should EXISTS in Pseduo refund receipt RCTH_Y1.RefundRecipient_ID, RCTH_Y1.RefundRecipient_CODE',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE a.Status_CODE = 'R'
      AND a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND b.StatusReceipt_CODE = 'R'
      AND (A.CheckRecipient_ID <> b.RefundRecipient_ID
            OR a.CheckRecipient_CODE <> b.RefundRecipient_CODE)
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'RECEIPT EXIST IN LSUP AND NOT IN RCTH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RECEIPT EXIST IN LSUP AND NOT IN RCTH',
          'FINANCIAL',
          'RCTH_Y1-LSUP_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE Batch_DATE <> '01/01/0001'
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'RECEIPT EXIST IN DHLD AND NOT IN RCTH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RECEIPT EXIST IN DHLD AND NOT IN RCTH',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
                         AND EndValidity_DATE = '12/31/9999')
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'Pseduo receipt RCTH.EventGlobalBeginSeq_NUMB should be populated in LSUP.EventGlobalSeq_NUMB';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Pseduo receipt RCTH.EventGlobalBeginSeq_NUMB should be populated in LSUP.EventGlobalSeq_NUMB',
          'FINANCIAL',
          'RCTH_Y1-LSUP_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '2'
     FROM LSUP_Y1 a,
          RCTH_Y1 b
    WHERE a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND a.EventFunctionalSeq_NUMB = 1820
      AND a.EventGlobalSeq_NUMB <> b. EventGlobalBeginSeq_NUMB
      AND EXISTS (SELECT 1
                    FROM DHLD_Y1 C
                   WHERE b.Batch_DATE = c.Batch_DATE
                     AND b.SourceBatch_CODE = c.SourceBatch_CODE
                     AND b.Batch_NUMB = c.Batch_NUMB
                     AND b.SeqReceipt_NUMB = c.SeqReceipt_NUMB
                     AND c.EndValidity_DATE = '12/31/9999')
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'Pseduo receipt RCTH.EventGlobalBeginSeq_NUMB should be populated in DHLD.EventGlobalSupportSeq_NUMB';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Pseduo receipt RCTH.EventGlobalBeginSeq_NUMB should be populated in DHLD.EventGlobalSupportSeq_NUMB',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '2'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND a.EventGlobalSupportSeq_NUMB <> b. EventGlobalBeginSeq_NUMB
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'Invalid EndValidity_DATE in ORDB_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid EndValidity_DATE in ORDB_Y1',
          'FINANCIAL',
          'ORDB_Y1',
          'EndValidity_DATE',
          CAST(a.EndValidity_DATE AS VARCHAR),
          COUNT (1),
          '1'
     FROM ORDB_Y1 a
    WHERE EndValidity_DATE <> '12/31/9999'
      AND YEAR(EndValidity_DATE) = '9999'
    GROUP BY CAST(a.EndValidity_DATE AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Unknown MCI should always be connected to the case as a Putative Father instead of NCP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Unknown MCI should always be connected to the case as a Putative Father instead of NCP',
          'CASE MANAGEMENT',
          'CMEM_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM cmem_Y1 a
    WHERE MemberMci_IDNO = 999995
      AND casememberStatus_CODE = 'A'
      AND caserelationship_code = 'A'
    GROUP BY Case_IDNO

   SET @Ls_Sql_TEXT = 'There cannot be a SORD record with the unknown MCI as the only active NCP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There cannot be a SORD record with the unknown MCI as the only active NCP',
          'CASE MANAGEMENT',
          'CMEM_Y1-SORD_Y1',
          'Case_IDNO',
          a.Case_IDNO,
          COUNT (1),
          '1'
     FROM cmem_Y1 a
    WHERE MemberMci_IDNO = 999995
      AND casememberStatus_CODE = 'A'
      AND caserelationship_code = 'A'
      AND EXISTS (SELECT *
                    FROM SORD_Y1
                   WHERE Case_IDNO = a.Case_IDNO)
    GROUP BY Case_IDNO

   SET @Ls_Sql_TEXT = 'SORD_Y1.ORDERENT_DATE SHOULD NOT BE HIGH DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'SORD_Y1.ORDERENT_DATE SHOULD NOT BE HIGH DATE',
          'FINANCIAL',
          'SORD_Y1',
          'ORDERENT_DATE',
          a.ORDERENT_DATE,
          COUNT (1),
          '1'
     FROM SORD_Y1 a
    WHERE a.ORDERENT_DATE = '12/31/9999'
    GROUP BY a.ORDERENT_DATE

   SET @Ls_Sql_TEXT = 'Cases with support order but still have PF';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Cases with support order but still have PF',
          'FINANCIAL',
          'CASE_Y1',
          'Case_IDNO',
          x.Entity_ID,
          x.ErrorCount_QNTY,
          '4'
     FROM (SELECT a.Case_IDNO AS Entity_ID,
                  COUNT(1) AS ErrorCount_QNTY,
                  COUNT(1) OVER () AS TotalRecords
             FROM CASE_Y1 a,
                  CMEM_Y1 b
            WHERE a.Case_IDNO = b.Case_IDNO
              AND a.StatusCase_CODE = 'O'
              AND b.CaseRelationship_CODE = 'P'
              AND b.CaseMemberStatus_CODE = 'A'
              AND EXISTS (SELECT 1
                            FROM SORD_Y1 s
                           WHERE s.Case_IDNO = a.Case_IDNO
                             AND s.EndValidity_DATE = '12/31/9999')
            GROUP BY a.Case_IDNO) x
    WHERE x.TotalRecords > 20;

   SET @Ls_Sql_TEXT = 'IV-D cases (Non TANF) cases with an application fee paid indicator is not blank but the application signed date is set to low date (01/01/0001))';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'IV-D cases (Non TANF) cases with an application fee paid indicator is not blank but the application signed date is set to low date (01/01/0001)',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'County_IDNO',
          CAST(a.Case_IDNO AS VARCHAR),
          COUNT (1),
          '3'
     FROM CASE_Y1 a
    WHERE a.typecase_code = 'N'
      AND a.respondinit_code IN ('N', 'I')
      AND a.casecategory_code = 'FS'
      AND a.StatusCase_CODE = 'O'
      AND a.appsigned_date = '01/01/0001'
      AND a.ApplicationFee_CODE <> ' '
    GROUP BY a.Case_IDNO

   SET @Ls_Sql_TEXT = 'IV-D cases current AND former assistance cases should have Application Fee Paid status set to Waived';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'IV-D cases current AND former assistance cases should have Application Fee Paid status set to Waived',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          CAST(Case_IDNO AS VARCHAR),
          COUNT (1),
          '3'
     FROM CASE_Y1 a
    WHERE (typecase_code IN ('A', 'F')
            OR (typecase_code = 'N'
                AND casecategory_code = 'FS'
                AND EXISTS (SELECT *
                              FROM mhis_Y1
                             WHERE Case_IDNO = a.Case_IDNO
                               AND typewelfare_code IN ('A', 'F', 'J'))))
      AND StatusCase_CODE = 'O'
      AND respondinit_code IN ('N', 'I')
      AND ApplicationFee_CODE NOT IN ('P', '')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'RCTNO Entity_ID invalid format. Correct format is ESEM.TypeEntity_CODE – “RCTNO” format is MM/DD/YYYY-3_Byte_SourceBatch_CODE-4_Byte_Batch_NUMB-First3Byte_SeqReceipt_NUMB-Last3Byte_SeqReceipt_NUMB';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RCTNO Entity_ID invalid format. Correct format is ESEM.TypeEntity_CODE – “RCTNO” format is MM/DD/YYYY-3_Byte_SourceBatch_CODE-4_Byte_Batch_NUMB-First3Byte_SeqReceipt_NUMB-Last3Byte_SeqReceipt_NUMB',
          'FINANCIAL',
          'ESEM_Y1',
          'Entity_ID',
          ES.Entity_ID,
          COUNT (1),
          '2'
     FROM ESEM_Y1 ES,
          GLEV_Y1 G
    WHERE ES.TypeEntity_CODE = 'RCTNO'
      AND G.EventGlobalSeq_NUMB = ES.EventGlobalSeq_NUMB
      AND LEN(Entity_ID) != 27
    GROUP BY ES.Entity_ID

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = P';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = P',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MemberMci_IDNO',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE = 'C'
      AND Status_CODE = 'P'
    GROUP BY MemberMci_IDNO

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = B AND End_DATE = 12/31/9999';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = B AND End_DATE = 12/31/9999',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE = 'C'
      AND Status_CODE = 'B'
      AND End_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = B AND End_DATE = 12/31/9999';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with TypeAddress_CODE = C AND the Status_CODE = B AND End_DATE = 12/31/9999',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE = 'C'
      AND Status_CODE = 'B'
      AND End_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with Status_CODE = B AND End_DATE = 12/31/9999';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with Status_CODE = B AND End_DATE = 12/31/9999',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE Status_CODE = 'B'
      AND End_DATE = '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with TypeAddress_CODE = M AND the Status_CODE = P AND End_DATE not equal to 12/31/9999';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with TypeAddress_CODE = M AND the Status_CODE = P AND End_DATE not equal to 12/31/9999',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE = 'M'
      AND Status_CODE = 'P'
      AND End_DATE <> '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'There should not be any records in AHIS with TypeAddress_CODE = R AND the Status_CODE = P AND End_DATE not equal to 12/31/9999';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'There should not be any records in AHIS with TypeAddress_CODE = R AND the Status_CODE = P AND End_DATE not equal to 12/31/9999',
          'CASE MANAGEMENT',
          'AHIS_Y1',
          'MEMBER',
          MemberMci_IDNO,
          COUNT (1),
          '2'
     FROM AHIS_Y1
    WHERE TypeAddress_CODE = 'R'
      AND Status_CODE = 'P'
      AND End_DATE <> '12/31/9999'
    GROUP BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'CSLN enforcement activity chain TypeOthpSource_CODE should be I';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CSLN enforcement activity chain TypeOthpSource_CODE should be I',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO-ActivityMajor_CODE-TypeOthpSource_code',
          CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeOthpSource_CODE,
          COUNT (1),
          '1'
     FROM dmjr_Y1
    WHERE ActivityMajor_CODE = 'CSLN'
      AND TypeOthpSource_CODE <> 'I'
      AND Status_CODE <> 'EXMT'
    GROUP BY CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeOthpSource_CODE;

   SET @Ls_Sql_TEXT = 'LSNR enforcement activity chain TypeOthpSource_CODE should be P';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSNR enforcement activity chain TypeOthpSource_CODE should be P',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO-ActivityMajor_CODE-TypeOthpSource_code',
          CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeOthpSource_CODE,
          COUNT (1),
          '1'
     FROM dmjr_Y1
    WHERE ActivityMajor_CODE = 'LSNR'
      AND Status_CODE <> 'EXMT'
      AND TypeOthpSource_CODE <> 'P'
    GROUP BY CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeOthpSource_CODE;

   SET @Ls_Sql_TEXT = 'MAPP activity chain CANNOT be associated with a OTHER PARTY. The source should always be a case member';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MAPP activity chain CANNOT be associated with a OTHER PARTY. The source should always be a case member',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO',
          OthpSource_IDNO,
          COUNT (1),
          '2'
     FROM DMJR_Y1
    WHERE ActivityMajor_CODE IN ('MAPP')
      AND TypeOthpSource_CODE NOT IN ('A', 'P')
    GROUP BY OthpSource_IDNO;

   SET @Ls_Sql_TEXT = 'DMNR Topic ID Number should be converted between 1 AND 60000000';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   (SELECT 'DMNR Topic ID Number should be converted between 1 AND 60000000',
           'CASE MANAGEMENT',
           'DMNR_Y1',
           'TopicID',
           Topic_Idno,
           COUNT (1),
           '2'
      FROM DMNR_Y1
     WHERE Topic_Idno NOT BETWEEN 1 AND 60000000
     GROUP BY Topic_Idno
    UNION
    SELECT 'DMNR Topic ID Number is not starts with 1',
           'CASE MANAGEMENT',
           'DMNR_Y1',
           'TopicID',
           MinTopic_Idno,
           1,
           '2'
      FROM (SELECT MIN(Topic_Idno) MinTopic_Idno
              FROM DMNR_Y1) s
     WHERE MinTopic_Idno != 1);

   SET @Ls_Sql_TEXT = 'Glec_Y1 TransactionEventSeq_NUMB should be converted between 1 AND 31653906';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Glec_Y1 TransactionEventSeq_NUMB should be converted between 1 AND 31653906',
          'All Subsystem',
          'GLEC_Y1',
          'TransactionEventSeq_NUMB',
          TransactionEventSeq_NUMB,
          COUNT (1),
          '2'
     FROM Glec_Y1
    WHERE TransactionEventSeq_NUMB NOT BETWEEN 1 AND 31653906
    GROUP BY TransactionEventSeq_NUMB
   UNION
   SELECT 'Glec_Y1 TransactionEventSeq_NUMB Number is not starts with 1',
          'All Subsystem',
          'GLEC_Y1',
          'TransactionEventSeq_NUMB',
          MinTransactionEventSeq_NUMB,
          1,
          '2'
     FROM (SELECT MIN(TransactionEventSeq_NUMB) MinTransactionEventSeq_NUMB
             FROM Glec_Y1) s
    WHERE MinTransactionEventSeq_NUMB != 1;

   SET @Ls_Sql_TEXT = 'Activity Minor WITH INVALID Forum_idno in DMNR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DMNR Forum_idno should be converted between 1 AND 180072106',
          'CASE MANAGEMENT',
          'DMNR_Y1',
          'Forum_idno',
          Forum_idno,
          COUNT (1),
          '2'
     FROM DMNR_Y1
    WHERE Forum_idno NOT BETWEEN 1 AND 180072106
    GROUP BY Forum_idno
   UNION
   SELECT 'DMNR Forum_idno Number is not starts with 1',
          'CASE MANAGEMENT',
          'DMNR_Y1',
          'Forum_idno',
          MinForum_idno,
          1,
          '2'
     FROM (SELECT MIN(Forum_idno) MinForum_idno
             FROM DMNR_Y1) s
    WHERE MinForum_idno != 1;

   SET @Ls_Sql_TEXT = 'INVALID EventGlobalSeq_NUMB in GLEC_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'GLEV_Y1 EventGlobalSeq_NUMB should be converted between 1 AND 31,653,906',
          'Financial',
          'GLEV_Y1',
          'EventGlobalSeq_NUMB',
          EventGlobalSeq_NUMB,
          COUNT (1),
          '2'
     FROM Glev_Y1
    WHERE EventGlobalSeq_NUMB NOT BETWEEN 1 AND 31653906
    GROUP BY EventGlobalSeq_NUMB
   UNION
   SELECT 'GLEV_Y1 EventGlobalSeq_NUMB Number is not starts with 1',
          'Financial',
          'GLEV_Y1',
          'EventGlobalSeq_NUMB',
          MinEventGlobalSeq_NUMB,
          1,
          '2'
     FROM (SELECT MIN(EventGlobalSeq_NUMB) MinEventGlobalSeq_NUMB
             FROM Glev_Y1) s
    WHERE MinEventGlobalSeq_NUMB != 1;

   SET @Ls_Sql_TEXT = 'NULL Value in ICAS_Y1.IVDOutOfStateFile_ID column';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NULL Value in ICAS_Y1.IVDOutOfStateFile_ID column',
          'CASE INITIATION',
          'ICAS_Y1',
          'IVDOutOfStateFile_ID',
          IVDOutOfStateFile_ID,
          COUNT (1),
          '2'
     FROM ICAS_Y1
    WHERE CHARINDEX (CHAR(0), IVDOutOfStateFile_ID) > 0
    GROUP BY IVDOutOfStateFile_ID

   SET @Ls_Sql_TEXT = 'The employment begin date in USEM_Y1 should not be low date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           ENTITY_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'The employment begin date in USEM_Y1 should not be low date',
          'MISCELLANEOUS',
          'USEM_Y1',
          'Worker_ID',
          A.Worker_ID,
          COUNT (1),
          '2'
     FROM USEM_Y1 A
    WHERE beginemployment_date = '01/01/0001'
      AND workerupdate_id = 'CONVERSION'
    GROUP BY A.Worker_ID;

   SET @Ls_Sql_TEXT = 'The expire date in USAM_Y1 table should not be set to low date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           ENTITY_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'The expire date in USAM_Y1 table should not be set to low date',
          'MISCELLANEOUS',
          'UASM_Y1',
          'Worker_ID',
          A.Worker_ID,
          COUNT (1),
          '2'
     FROM UASM_Y1 A
    WHERE expire_date = '01/01/0001'
      AND workerupdate_id = 'CONVERSION'
    GROUP BY A.Worker_ID;

   SET @Ls_Sql_TEXT = 'Invalid SourceLocConf_CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid SourceLocConf_CODE',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'SourceLocConf_CODE',
          SourceLocConf_CODE,
          COUNT (1),
          '3'
     FROM EHIS_Y1 a
    WHERE NOT EXISTS(SELECT 1
                       FROM refm_Y1 b
                      WHERE Table_ID = 'EHIS'
                        AND TableSub_ID = 'VERF'
                        AND a.SourceLocConf_CODE = Value_CODE)
    GROUP BY SourceLocConf_CODE;

   SET @Ls_Sql_TEXT = 'File_ID Matches between CASE_Y1 AND SORD_Y1 but not exist in DCKT_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'File_ID Matches between CASE_Y1 AND SORD_Y1 but not exist in DCKT_Y1',
          'CASE INITIATION',
          'CASE_Y1',
          'Case_IDNO',
          CAST(a.Case_IDNO AS VARCHAR),
          COUNT (1),
          '2'
     FROM CASE_Y1 a,
          SORD_Y1 b
    WHERE a.Case_IDNO = b.Case_IDNO
      AND b.EndValidity_DATE = '12/31/9999'
      AND a.File_ID = b.File_ID
      AND a.File_ID <> ' '
      AND a.File_ID NOT IN (SELECT File_ID
                              FROM DCKT_Y1)
    GROUP BY a.Case_IDNO

   SET @Ls_Sql_TEXT = 'All Open Case should have record in ACES table'

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'All Open Case should have record in ACES table',
          'CASE INITIATION',
          'CASE_Y1',
          'Case_IDNO',
          CAST(a.Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE StatusCase_CODE = 'O'
      AND NOT EXISTS (SELECT 1
                        FROM aces_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO)
    GROUP BY a.Case_IDNO

   SET @Ls_Sql_TEXT = 'File_ID exist in DCKT_Y1 AND DPRS_Y1 tables but not exist in DPRS_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           ENTITY_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'File_ID exist in DCKT_Y1 AND DPRS_Y1 tables but not exist in DPRS_Y1 table',
          'FINANCIAL',
          'DCKT_Y1',
          'Judge_ID',
          Judge_ID,
          COUNT (1),
          '2'
     FROM DCKT_Y1
    WHERE File_ID NOT IN (SELECT DISTINCT
                                 File_ID
                            FROM dprs_Y1)
      AND File_ID IN (SELECT DISTINCT
                             File_ID
                        FROM CASE_Y1)
    GROUP BY Judge_ID;

   SET @Ls_Sql_TEXT = 'File Date in DCKT table cannot be high date or low date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           ENTITY_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'File Date in DCKT table cannot be high date or low date',
          'FINANCIAL',
          'DCKT_Y1',
          'Judge_ID',
          Judge_ID,
          COUNT (1),
          '2'
     FROM DCKT_Y1
    WHERE filed_date IN ('01/01/0001', '12/31/9999')
    GROUP BY Judge_ID

   SET @Ls_Sql_TEXT = 'Cases have receipts in RCTH but they do not have any obligation records in OBLE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Cases have receipts in RCTH but they do not have any obligation records in OBLE',
          'FINANCIAL',
          'RCTH_Y1',
          'Batch_DATE',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM rcth_Y1 a
    WHERE Case_IDNO <> 0
      AND Case_IDNO NOT IN (SELECT DISTINCT
                                   Case_IDNO
                              FROM oble_Y1)
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'All dmnr Forum ID should match with Dmjr for the Corresponding Case ID AND MajorIntSeq_NUMB';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'All dmnr Forum ID should match with Dmjr for the Corresponding Case ID AND MajorIntSeq_NUMB',
          'ENFORCEMENT',
          'DMNR_Y1',
          'Case_IDNO',
          n.Case_IDNO,
          COUNT (1),
          '2'
     FROM DMNR_Y1 n
    WHERE EXISTS(SELECT 1
                   FROM dmjr_Y1 j
                  WHERE j.Case_IDNO = n.Case_IDNO
                    AND j.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
                    AND j.Forum_idno != n.Forum_idno)
      AND Status_CODE = 'STRT'
      AND workerupdate_id IN ('CONVERSION')
    GROUP BY n.Case_IDNO

   SET @Ls_Sql_TEXT = 'ReasonStatus_CODE should be blank for the active records in DMNR';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ReasonStatus_CODE should be blank for the active records in DMNR',
          'ENFORCEMENT',
          'DMNR_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM dmnr_Y1
    WHERE Status_CODE = 'STRT'
      AND ReasonStatus_CODE != ''
    GROUP BY Case_IDNO

   SET @Ls_Sql_TEXT = 'The Transaction Event sequence of DMNR_Y1 AND SWKS_Y1 should be same for all CPRO Major activities(Except CASE)';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'The Transaction Event sequence of DMNR_Y1 AND SWKS_Y1 should be same for all CPRO Major activities(Except CASE)',
          'ENFORCEMENT',
          'DMNR_Y1',
          'Case_IDNO',
          d.Case_IDNO,
          COUNT (1),
          '1'
     FROM SWKS_Y1 s,
          DMNR_Y1 d
    WHERE d.Schedule_NUMB = s.Schedule_NUMB
      AND d.TransactionEventSeq_NUMB != s.TransactionEventSeq_NUMB
      AND s.ActivityMajor_CODE != 'CASE'
    GROUP BY d.Case_IDNO

   SET @Ls_Sql_TEXT = 'Cases with no obligations but have open DMJR remedies.These cases  have open IMIW, NMSN, FIDM, CSLN, OBRA, AND EMNP remedies open. All of these remedies need an obligation';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Cases with no obligations but have open DMJR remedies.These cases  have open IMIW, FIDM, CSLN, OBRA, and EMNP remedies open. All of these remedies need an obligation',
          'ENFORCEMENT',
          'DMJR_Y1',
          'a.Case_IDNO-a.typecase_code-a.casecategory_code-a.StatusCase_CODE-a.worker_id-b.MemberMci_IDNO-b.activitymajor_code-b.Status_CODE-b.othpsource_idno-b.typeothpsource_code-b.reference_id',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + a.typecase_code + '-' + a.casecategory_code + '-' + a.StatusCase_CODE + '-' + CAST(RTRIM(a.worker_id) AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR) + '-' + b.activitymajor_code + '-' + b.Status_CODE + '-' + CAST(b.othpsource_idno AS VARCHAR) + '-' + b.typeothpsource_code + '-' + CAST(b.reference_id AS VARCHAR),
          COUNT(1),
          '1'
     FROM CASE_Y1 a,
          dmjr_Y1 b
    WHERE a.Case_IDNO = b.Case_IDNO
      AND a.StatusCase_CODE = 'O'
      AND b.activitymajor_code NOT IN ('CCLO', 'ESTP', 'MAPP', 'NMSN', 'CASE')
      AND b.Status_CODE <> 'EXMT'
      AND EXISTS (SELECT *
                    FROM SORD_Y1
                   WHERE Case_IDNO = a.Case_IDNO)
      AND NOT EXISTS (SELECT *
                        FROM oble_Y1
                       WHERE Case_IDNO = a.Case_IDNO)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + a.typecase_code + '-' + a.casecategory_code + '-' + a.StatusCase_CODE + '-' + CAST(RTRIM(a.worker_id) AS VARCHAR) + '-' + CAST(b.MemberMci_IDNO AS VARCHAR) + '-' + b.activitymajor_code + '-' + b.Status_CODE + '-' + CAST(b.othpsource_idno AS VARCHAR) + '-' + b.typeothpsource_code + '-' + CAST(b.reference_id AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Invalid intercept code in CASE_Y1 table. Possible values are S - Certified for State, I - Certified for IRS, B - Certified for both AND N - Not Certified';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid intercept code in CASE_Y1 table. Possible values are S - Certified for State, I - Certified for IRS, B - Certified for both AND N - Not Certified',
          'CASE INITIATION',
          'CASE_Y1',
          'Case_IDNO-Intercept_CODE',
          CAST(Case_IDNO AS VARCHAR) + '-' + Intercept_CODE,
          COUNT (1),
          '1'
     FROM CASE_Y1
    WHERE intercept_code NOT IN('S', 'I', 'B', 'N')
    GROUP BY CAST(Case_IDNO AS VARCHAR) + '-' + Intercept_CODE

   SET @Ls_Sql_TEXT = 'Employment begin date should not be highdate';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Employment begin date should not be highdate',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MemberMci_IDNO-BeginEmployment_DATE',
          CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(BeginEmployment_DATE AS VARCHAR),
          COUNT (1),
          '3'
     FROM ehis_Y1
    WHERE beginemployment_date = '12/31/9999'
      AND endemployment_date > @Ad_Conversion_DATE
    GROUP BY CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(BeginEmployment_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Employment begin date is in future year';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Employment begin date is in future year',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'MemberMci_IDNO-BeginEmployment_DATE',
          CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(BeginEmployment_DATE AS VARCHAR),
          COUNT (1),
          '2'
     FROM ehis_Y1
    WHERE YEAR(beginemployment_date) > YEAR(GETDATE())
      AND beginemployment_date < '12/31/9999'
      AND endemployment_date > @Ad_Conversion_DATE
    GROUP BY CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(BeginEmployment_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'When a worker from a county office is assigned to a case with a specific role, then a corresponding entry must exist in USRL for the worker, office, AND Role combination. Currently there is no corresponding USRL record for the workers assigned to cases in CWRK';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'When a worker from a county office is assigned to a case with a specific role, then a corresponding entry must exist in USRL for the worker, office, AND Role combination. Currently there is no corresponding USRL record for the workers assigned to cases in CWRK',
          'CASE MANAGEMENT',
          'EHIS_Y1',
          'Worker_ID-Office_IDNO',
          CAST(RTRIM(Worker_ID) AS VARCHAR) + '-' + CAST(Office_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM cwrk_Y1 a
    WHERE NOT EXISTS (SELECT *
                        FROM usrl_Y1
                       WHERE Worker_ID = a.Worker_ID
                         AND office_idno = a.Office_IDNO)
    GROUP BY CAST(RTRIM(Worker_ID) AS VARCHAR) + '-' + CAST(Office_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) in AHIS_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) in AHIS_Y1 table',
          'ENFORCEMENT',
          'AHIS_Y1',
          'MemberMci_IDNO-Zip_ADDR',
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR),
          COUNT (1),
          '3'
     FROM AHIS_Y1 a
    WHERE Country_ADDR = 'US'
      AND LTRIM(RTRIM(Zip_ADDR)) <> ''
      AND ISNUMERIC(Zip_ADDR) = 0
    GROUP BY CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) OTHP_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) in OTHP_Y1 table',
          'ENFORCEMENT',
          'OTHP_Y1',
          'OtherParty_IDNO-Zip_ADDR',
          CAST(a.OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR),
          COUNT (1),
          '3'
     FROM OTHP_Y1 a
    WHERE EndValidity_DATE = '12/31/9999'
      AND Country_ADDR = 'US'
      AND LTRIM(RTRIM(Zip_ADDR)) <> ''
      AND ISNUMERIC(Zip_ADDR) = 0
    GROUP BY CAST(a.OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) in CSDB_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Zip should have only numeric value without any special character(Hypen or Space or other Special char) in CSDB_Y1 table',
          'CASE MANAGEMENT',
          'CSDB_Y1',
          'TransHeader_IDNO-PaymentZip_ADDR-ContactZip_ADDR',
          CAST(a.TransHeader_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(PaymentZip_ADDR)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(ContactZip_ADDR)) AS VARCHAR),
          COUNT (1),
          '3'
     FROM CSDB_Y1 a
    WHERE ((LTRIM(RTRIM(PaymentZip_ADDR)) <> ''
        AND ISNUMERIC(PaymentZip_ADDR) = 0)
        OR (LTRIM(RTRIM(ContactZip_ADDR)) <> ''
            AND ISNUMERIC(ContactZip_ADDR) = 0))
    GROUP BY CAST(a.TransHeader_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(PaymentZip_ADDR)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(ContactZip_ADDR)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Country code should not be blank AND addresses should not be in Canada in OTHP_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Country code should not be blank AND addresses should not be in Canada in OTHP_Y1 table',
          'ENFORCEMENT',
          'OTHP_Y1',
          'OtherParty_IDNO-Country_ADDR-Zip_ADDR',
          CAST(OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Country_ADDR)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR),
          COUNT (1),
          '3'
     FROM OTHP_Y1
    WHERE LTRIM(RTRIM(Country_ADDR)) = ''
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Country_ADDR)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Zip_ADDR)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'FIDM enforcement activity chain TypeReference_CODE should not be INS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'FIDM enforcement activity chain TypeReference_CODE should not be INS',
          'ENFORCEMENT',
          'DMJR_Y1',
          'OthpSource_IDNO-ActivityMajor_CODE-TypeReference_CODE',
          CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeReference_CODE,
          COUNT (1),
          '1'
     FROM dmjr_Y1
    WHERE ActivityMajor_CODE = 'FIDM'
      AND TypeReference_CODE = 'INS'
    GROUP BY CAST(OthpSource_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + TypeReference_CODE;

   SET @Ls_Sql_TEXT = 'DMNR WorkerDelegate_ID should not be blank for assigned alert Minor Activities';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DMNR WorkerDelegate_ID should not be blank for assigned alert Minor Activities',
          'CASE MANAGEMENT',
          'DMNR_Y1',
          'WorkerDelegate_ID',
          WorkerDelegate_ID,
          COUNT (d.WorkerDelegate_ID),
          '1'
     FROM acrl_Y1 a,
          dmnr_Y1 d
    WHERE a.workerassign_indc = 'Y'
      AND a.role_id <> ' '
      AND d.WorkerDelegate_ID = ' '
      AND a.ActivityMinor_code = d.ActivityMinor_code
      AND a.SubCategory_CODE = d.ActivityMajor_code
      AND d.Status_CODE = 'STRT'
      AND d.ActivityMinor_code IN (SELECT ActivityMinor_code
                                     FROM AMNR_Y1
                                    WHERE actionalert_code IN ('A', 'I'))
    GROUP BY d.WorkerDelegate_ID;

   SET @Ls_Sql_TEXT = 'OTHP Office Type Record should not be converted';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'OTHP Office Type Record should not be converted',
          'EOU',
          'OTHP_Y1',
          'OtherParty_IDNO-TypeOthp_CODE',
          CAST(a.OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(TypeOthp_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(OtherParty_NAME)) AS VARCHAR),
          COUNT (1),
          '1'
     FROM OTHP_Y1 a
    WHERE TypeOthp_CODE = 'O'
      AND WorkerUpdate_ID LIKE 'CONVERSION'
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CAST(a.OtherParty_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(TypeOthp_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(OtherParty_NAME)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Member Assets - Attorney OTHP ID Not Matching in OTHP_Y1 Table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Member Assets - Attorney OTHP ID Not Matching in OTHP_Y1 Table',
          'CI',
          'ASFN_Y1',
          'MemberMci_IDNO-OthpAtty_IDNO',
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.Asset_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.OthpAtty_IDNO)) AS VARCHAR),
          COUNT (1),
          '2'
     FROM ASFN_Y1 a
    WHERE a.EndValidity_DATE = '12/31/9999'
      AND a.OthpAtty_IDNO != 0
      AND a.Asset_CODE != 'INS'
      AND NOT EXISTS (SELECT o.OtherParty_IDNO
                        FROM Othp_y1 o
                       WHERE o.OtherParty_IDNO = a.OthpInsFin_IDNO
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.Asset_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(a.OthpAtty_IDNO)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'For SORD_Y1.IIWO_CODE = S records DMJR record should be converted with ActivityMajor_CODE = IMIW, Status_CODE = EXMT, ReasonStatus_CODE = CO, BeginExempt_DATE = CONVERSION DATE AND EndExempt_DATE = HIGH DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'For SORD_Y1.IIWO_CODE = S records DMJR record should be converted with ActivityMajor_CODE = IMIW, Status_CODE = EXMT, ReasonStatus_CODE = CO, BeginExempt_DATE = CONVERSION DATE and EndExempt_DATE = HIGH DATE',
          'ENFORCEMENT',
          'SORD_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM SORD_Y1 a
    WHERE iiwo_code = 'S'
      AND EndValidity_DATE > @Ad_Conversion_DATE
      AND EndValidity_DATE < '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM dmjr_y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND activitymajor_code = 'IMIW'
                         AND Status_CODE = 'EXMT'
                         AND b.reasonStatus_CODE = 'CO'
                         AND beginexempt_date = '05/01/2012'
                         AND endexempt_date = '12/31/9999')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'The other party on MAST does not exist in OTHP table with the correct OTHP Type – FIN type assets must be linked to OTHP Type H';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'The other party on MAST does not exist in OTHP table with the correct OTHP Type – FIN type assets must be linked to OTHP Type H' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'ASFN_Y1' AS Table_NAME,
          'OthpInsFin_IDNO' AS EntityType_TEXT,
          a.OthpInsFin_IDNO AS ENTITY_ID,
          COUNT (1),
          '1' AS ErrorCount_QNTY
     FROM ASFN_Y1 A
    WHERE Asset_CODE <> 'INS'
      AND NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 O
                       WHERE O.OtherParty_IDNO = A.OthpInsFin_IDNO
                         AND o.TypeOthp_CODE = 'H'
                         AND EndValidity_DATE = '12/31/9999')
      AND A.EndValidity_DATE = '12/31/9999'
    GROUP BY a.OthpInsFin_IDNO

   SET @Ls_Sql_TEXT = 'Case is Close, Enforcement & Establishment Status Should be Closed';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Case is Close, Enforcement & Establishment Status Should be Closed',
          'CI',
          'CASE_Y1,ACES_Y1,ACEN_Y1',
          'Case_IDNO-StatusCase_CODE-STATUSESTABLISH_CODE-STATUSENFORCE_CODE',
          CAST(C.Case_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(C.StatusCase_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(A.STATUSESTABLISH_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(N.STATUSENFORCE_CODE)) AS VARCHAR),
          COUNT (1),
          '2'
     FROM CASE_Y1 C
          JOIN ACES_Y1 A
           ON A.Case_IDNO = C.Case_IDNO
              AND A.STATUSESTABLISH_CODE = 'O'
              AND A.EndValidity_DATE = '12/31/9999'
          JOIN ACEN_Y1 N
           ON N.Case_IDNO = C.Case_IDNO
              AND N.STATUSENFORCE_CODE = 'O'
              AND N.EndValidity_DATE = '12/31/9999'
    WHERE C.StatusCase_CODE = 'C'
      AND C.WorkerUpdate_ID LIKE 'CONVERSION'
    GROUP BY CAST(C.Case_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(C.StatusCase_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(A.STATUSESTABLISH_CODE)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(N.STATUSENFORCE_CODE)) AS VARCHAR);

   SET @Ls_Sql_TEXT = 'EXPIRE DATE CANNOT HAVE LOW DATE IN UASM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'EXPIRE DATE CANNOT HAVE LOW DATE IN UASM_Y1' AS Reason,
          'SECURITY' AS Subsystem,
          'UASM_Y1',
          'EXPIRE_DATE',
          CAST(U.EXPIRE_DATE AS VARCHAR),
          COUNT(1),
          '2'
     FROM UASM_Y1 U
    WHERE U.Expire_DATE = '0001-01-01'
    GROUP BY EXPIRE_DATE;

   SET @Ls_Sql_TEXT = 'Workers FIRST_NAME should not be empty IN USEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Workers FIRST_NAME should not be empty IN USEM_Y1' AS Reason,
          'SECURITY' AS Subsystem,
          'USEM_Y1',
          'FIRST_NAME',
          CAST(U.FIRST_NAME AS VARCHAR),
          COUNT(1),
          '1'
     FROM USEM_Y1 U
    WHERE U.FIRST_NAME = ''
    GROUP BY FIRST_NAME;

   SET @Ls_Sql_TEXT = 'Workers LAST_NAME should not be empty IN USEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Workers LAST_NAME should not be empty IN USEM_Y1' AS Reason,
          'SECURITY' AS Subsystem,
          'USEM_Y1',
          'LAST_NAME',
          CAST(U.LAST_NAME AS VARCHAR),
          COUNT(1),
          '1'
     FROM USEM_Y1 U
    WHERE U.LAST_NAME = ''
    GROUP BY LAST_NAME;

   SET @Ls_Sql_TEXT = 'R.I (MINS_OTHP) MINS_Y1.OthpInsurance_IDNO(INSURANCE) NOT IN OTHP_Y1.OtherParty_IDNO';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (MINS_OTHP) MINS_Y1.OthpInsurance_IDNO(INSURANCE) NOT IN OTHP_Y1.OtherParty_IDNO' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'MINS_Y1' AS Table_NAME,
          'OthpInsurance_IDNO' AS EntityType_TEXT,
          a.OthpInsurance_IDNO AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM MINS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM OTHP_Y1 O
                       WHERE O.OtherParty_IDNO = A.OthpInsurance_IDNO
                         AND EndValidity_DATE = '12/31/9999')
      AND a.EndValidity_DATE = '12/31/9999'
    GROUP BY a.OthpInsurance_IDNO;

   SET @Ls_Sql_TEXT = 'R.I  MINS_Y1.Status_DATE(Status Date) NEED TO UPDATE WITH VALID DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I  MINS_Y1.Status_DATE(Status Date) NEED TO UPDATE WITH VALID DATE' AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'MINS_Y1' AS Table_NAME,
          'OthpInsurance_IDNO , Status_DATE' AS EntityType_TEXT,
          CAST(a.OthpInsurance_IDNO AS VARCHAR(MAX)) + ' , ' + CAST(Status_DATE AS VARCHAR(MAX)) AS ENTITY_ID,
          COUNT (1),
          '2' AS ErrorCount_QNTY
     FROM MINS_Y1 a
    WHERE a.EndValidity_DATE = '12/31/9999'
      AND Status_DATE = '0001-01-01'
    GROUP BY CAST(a.OthpInsurance_IDNO AS VARCHAR(MAX)) + ' , ' + CAST(Status_DATE AS VARCHAR(MAX))

   SET @Ls_Sql_TEXT = 'CLOSED CASE CANNOT HAVE IN-PROGRESS REMEDIES';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CLOSED CASE CANNOT HAVE IN-PROGRESS REMEDIES' AS Reason,
          'ENFORCEMENT' AS SubSystem,
          'DMJR_Y1',
          'Case_IDNO-ActivityMajor_CODE',
          CAST(j.Case_IDNO AS VARCHAR) + '-' + CAST(j.ActivityMajor_CODE AS VARCHAR),
          COUNT(1),
          '1'
     FROM DMJR_Y1 j
    WHERE j.Status_CODE = 'STRT'
      AND j.WorkerUpdate_ID = 'CONVERSION'
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 c
                   WHERE c.Case_IDNO = j.Case_IDNO
                     AND c.StatusCase_CODE = 'C')
    GROUP BY j.Case_IDNO,
             j.ActivityMajor_CODE;

   SET @Ls_Sql_TEXT = 'Missing OTHP Source Type Code for Activity Major';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Missing OTHP Source Type Code for Activity Major' AS Reason,
          'ENFORCEMENT' AS SubSystem,
          'DMJR_Y1',
          'Case_IDNO-ActivityMajor_CODE-TypeOTHPSource_CODE-OTHPSource_IDNO',
          CAST(j.Case_IDNO AS VARCHAR) + '-' + CAST(j.ActivityMajor_CODE AS VARCHAR) + '-' + CAST(j.TypeOthpSource_CODE AS VARCHAR) + '-' + CAST(j.OthpSource_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM DMJR_Y1 j
    WHERE j.Status_CODE != 'EXMT'
      AND j.ActivityMajor_CODE != 'CASE'
      AND NOT EXISTS (SELECT 1
                        FROM REFM_Y1 r
                       WHERE r.Table_ID = j.ActivityMajor_CODE
                         AND r.TableSub_ID = 'SRCT'
                         AND j.TypeOthpSource_CODE = r.Value_CODE)
    GROUP BY j.Case_IDNO,
             j.ActivityMajor_CODE,
             j.TypeOthpSource_CODE,
             j.OthpSource_IDNO;

   SET @Ls_Sql_TEXT = 'Incorrect OTHP Source Type Code for Activity Major';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Incorrect OTHP Source Type Code for Activity Major' AS Reason,
          'ENFORCEMENT' AS SubSystem,
          'DMJR_Y1',
          'Case_IDNO-ActivityMajor_CODE-TypeOTHPSource_CODE-OTHPSource_IDNO',
          CAST(j.Case_IDNO AS VARCHAR) + '-' + CAST(j.ActivityMajor_CODE AS VARCHAR) + '-' + CAST(j.TypeOthpSource_CODE AS VARCHAR) + '-' + CAST(j.OthpSource_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM DMJR_Y1 j
    WHERE j.Status_CODE != 'EXMT'
      AND j.ActivityMajor_CODE != 'CASE'
      AND ((j.TypeOthpSource_CODE IN ('A', 'P', 'D', 'C')
            AND j.ActivityMajor_CODE IN ('AREN', 'CCLO', 'COOP', 'CRIM',
                                         'CRPT', 'EMNP', 'ESTP', 'GTST',
                                         'LINT', 'MAPP', 'OBRA', 'PSOC',
                                         'SEQO', 'VAPP')
            AND NOT EXISTS (SELECT 1
                              FROM CMEM_Y1 c
                             WHERE c.Case_IDNO = j.Case_IDNO
                               AND c.CaseRelationShip_CODE = j.TypeOthpSource_CODE
                               AND c.CaseMemberStatus_CODE = 'A'))
            OR (j.ActivityMajor_CODE = 'LSNR'
                AND NOT EXISTS (SELECT 1
                                  FROM OTHP_Y1 o
                                       JOIN PLIC_Y1 l
                                        ON o.OtherParty_IDNO = l.OthpLicAgent_IDNO
                                 WHERE o.EndValidity_DATE = '12/31/9999'
                                   AND o.OtherParty_IDNO = j.OthpSource_IDNO
                                   AND o.TypeOthp_CODE = j.TypeOthpSource_CODE
                                   AND l.MemberMci_IDNO = j.MemberMci_IDNO
                                   AND l.LicenseStatus_CODE != 'E'
                                   AND l.ExpireLicense_DATE >= @Ad_Conversion_DATE
                                   AND l.EndValidity_DATE = '12/31/9999'))
            OR (j.ActivityMajor_CODE = 'FIDM'
                AND NOT EXISTS (SELECT 1
                                  FROM OTHP_Y1 o
                                       JOIN ASFN_Y1 f
                                        ON o.OtherParty_IDNO = f.OthpInsFin_IDNO
                                 WHERE o.EndValidity_DATE = '12/31/9999'
                                   AND o.TypeOthp_CODE = j.TypeOthpSource_CODE
                                   AND o.OtherParty_IDNO = j.OthpSource_IDNO
                                   AND f.MemberMci_IDNO = j.MemberMci_IDNO
                                   AND f.Asset_CODE IN ('02', '04', '05', '06',
                                                        '03', '12', '07', '11',
                                                        '18', '08', '09', '14',
                                                        '01', '10', '17', '16', '13')
                                   AND f.EndValidity_DATE = '12/31/9999'
                                   AND f.Status_CODE = 'Y'))
            OR (j.ActivityMajor_CODE IN ('CSLN', 'LIEN')
                AND NOT EXISTS (SELECT 1
                                  FROM OTHP_Y1 o
                                       JOIN ASFN_Y1 f
                                        ON o.OtherParty_IDNO = f.OthpInsFin_IDNO
                                 WHERE o.EndValidity_DATE = '12/31/9999'
                                   AND o.TypeOthp_CODE = j.TypeOthpSource_CODE
                                   AND o.OtherParty_IDNO = j.OthpSource_IDNO
                                   AND f.MemberMci_IDNO = j.MemberMci_IDNO
                                   AND f.Asset_CODE = 'INS'
                                   AND f.EndValidity_DATE = '12/31/9999'
                                   AND f.Status_CODE = 'Y'))
            OR (j.ActivityMajor_CODE IN ('NMSN')
                AND NOT EXISTS (SELECT 1
                                  FROM OTHP_Y1 o
                                       JOIN EHIS_Y1 e
                                        ON e.OthpPartyEmpl_IDNO = o.OtherParty_IDNO
                                           AND e.EndEmployment_DATE >= GETDATE()
                                           AND e.Status_CODE = 'Y'
                                       JOIN CMEM_Y1 d
                                        ON d.MemberMci_IDNO = e.MemberMci_IDNO
                                           AND d.Case_IDNO = j.Case_IDNO
                                           AND d.CaseRelationship_CODE IN ('C', 'A')
                                           AND d.CaseMemberStatus_CODE = 'A'
                                 WHERE o.EndValidity_DATE = '12/31/9999'
                                   AND o.TypeOthp_CODE = j.TypeOthpSource_CODE
                                   AND o.OtherParty_IDNO = j.OthpSource_IDNO))
            OR (j.ActivityMajor_CODE IN ('IMIW')
                AND NOT EXISTS (SELECT 1
                                  FROM OTHP_Y1 o
                                       JOIN EHIS_Y1 e
                                        ON o.OtherParty_IDNO = e.OthpPartyEmpl_IDNO
                                 WHERE o.EndValidity_DATE = '12/31/9999'
                                   AND j.TypeOthpSource_CODE IN ('G', 'E', 'I', 'W',
                                                                 'M', '9', 'U')
                                   AND e.MemberMci_IDNO = j.MemberMci_IDNO
                                   AND e.EndEmployment_DATE >= GETDATE()
                                   AND e.Status_CODE = 'Y'
                                   AND (e.TypeIncome_CODE IN (CASE j.TypeOthpSource_CODE
                                                               WHEN 'E'
                                                                THEN 'EM'
                                                               WHEN 'I'
                                                                THEN 'CS'
                                                               WHEN 'W'
                                                                THEN 'WC'
                                                               WHEN 'M'
                                                                THEN 'ML'
                                                               WHEN '9'
                                                                THEN 'SS'
                                                               WHEN 'G'
                                                                THEN 'RT'
                                                              END)
                                         OR e.TypeIncome_CODE IN (CASE j.TypeOthpSource_CODE
                                                                   WHEN 'G'
                                                                    THEN 'VP'
                                                                  END))
                                   AND o.TypeOthp_CODE = j.TypeOthpSource_CODE
                                   AND o.OtherParty_IDNO = j.OthpSource_IDNO))
            OR (j.ActivityMajor_CODE IN ('ROFO')
                AND NOT EXISTS (SELECT 1
                                  FROM FIPS_Y1 f,
                                       ICAS_Y1 s,
                                       CMEM_Y1 c
                                 WHERE s.RespondInit_CODE IN ('R', 'Y', 'S')
                                   AND s.IVDOutOfStateFips_CODE = f.StateFips_CODE
                                   AND s.IVDOutOfStateCountyFips_CODE = f.CountyFips_CODE
                                   AND ((f.TypeAddress_CODE = 'STA'
                                         AND f.SubTypeAddress_CODE = 'CRG'
                                         AND (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE)) = '000'
                                               OR (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE))) IS NULL)
                                         AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = '00'
                                               OR (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE))) IS NULL))
                                         OR (f.TypeAddress_CODE = 'LOC'
                                             AND f.SubTypeAddress_CODE = 'C01'
                                             AND (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE)) <> '000'
                                                   OR (RTRIM(LTRIM(s.IVDOutOfStateCountyFips_CODE))) IS NOT NULL))
                                         OR (f.TypeAddress_CODE = 'INT'
                                             AND f.SubTypeAddress_CODE = 'FRC'
                                             AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = '00'
                                                   OR (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE))) IS NULL))
                                         OR (f.TypeAddress_CODE = 'TRB'
                                             AND f.SubTypeAddress_CODE = 'T01'
                                             AND (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE)) = '00'
                                                   OR (RTRIM(LTRIM(s.IVDOutOfStateOfficeFips_CODE))) IS NULL)))
                                   AND f.EndValidity_DATE = '12/31/9999'
                                   AND s.Status_CODE = 'O'
                                   AND s.EndValidity_DATE = '12/31/9999'
                                   AND GETDATE() BETWEEN s.Effective_DATE AND s.End_DATE
                                   AND s.Case_IDNO = j.Case_IDNO
                                   AND c.Case_IDNO = j.Case_IDNO
                                   AND c.CaseRelationship_CODE = 'C'
                                   AND c.MemberMci_IDNO = j.OthpSource_IDNO
                                   AND f.Fips_CODE = j.Reference_ID
                                   AND c.CaseMemberStatus_CODE = 'A')))
    GROUP BY j.Case_IDNO,
             j.ActivityMajor_CODE,
             j.TypeOthpSource_CODE,
             j.OthpSource_IDNO;

   SET @Ls_Sql_TEXT = 'CWRK - ASSIGNED CASE WORKER PROFILE IS END DATED BUT ROLE IS NOT END DATED TO MATCH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CWRK - ASSIGNED CASE WORKER PROFILE IS END DATED BUT ROLE IS NOT END DATED TO MATCH' AS Reason,
          'CASE MANAGEMENT' AS Subsystem,
          'CWRK_Y1',
          'WORKER_ID-ROLE_ID',
          CAST(LTRIM(RTRIM(worker_id)) AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(Role_ID)) AS VARCHAR),
          COUNT(1),
          '2'
     FROM cwrk_y1 a
    WHERE EXISTS (SELECT *
                    FROM usem_y1
                   WHERE worker_id = a.worker_id
                     AND EndValidity_DATE <= @Ad_Conversion_DATE)
      AND EXISTS (SELECT *
                    FROM uasm_y1
                   WHERE worker_id = a.worker_id
                     AND office_idno = a.office_idno
                     AND (EndValidity_DATE <= @Ad_Conversion_DATE
                           OR Expire_date <= @Ad_Conversion_DATE))
      AND NOT EXISTS (SELECT *
                        FROM usrl_y1
                       WHERE worker_id = a.worker_id
                         AND office_idno = a.office_idno
                         AND Role_id = a.role_id
                         AND (EndValidity_DATE <= @Ad_Conversion_DATE
                               OR Expire_date <= @Ad_Conversion_DATE))
    GROUP BY worker_id,
             role_id;

   SET @Ls_Sql_TEXT = 'INCORRECT CODE FOR INTERNATIONAL INITIATING CASE IN CASE AND ICAS. RESPONDINIT_CODE SHOULD BE C-Initating International';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'INCORRECT CODE FOR INTERNATIONAL INITIATING CASE IN CASE AND ICAS. RESPONDINIT_CODE SHOULD BE C-Initating International',
          'INTERSTATE',
          'ICASE_Y1-CASE_Y1',
          'Case_IDNO-RESPONDINIT_CODE',
          CAST(A.Case_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(A.RESPONDINIT_CODE)) AS VARCHAR),
          COUNT (1),
          '1'
     FROM ICAS_Y1 A,
          CASE_Y1 B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND IVDOutOfStateFips_CODE BETWEEN 'A' AND 'Z'
      AND A.RESPONDINIT_CODE = B.RESPONDINIT_CODE
      AND A.RespondInit_CODE = 'I'
    GROUP BY A.Case_IDNO,
             A.RESPONDINIT_CODE;

   SET @Ls_Sql_TEXT = 'INCORRECT CODE FOR INTERNATIONAL RESPONDING CASE IN CASE AND ICAS. RESPONDINIT_CODE SHOULD BE Y-Responding International';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'INCORRECT CODE FOR INTERNATIONAL RESPONDING CASE IN CASE AND ICAS. RESPONDINIT_CODE SHOULD BE Y-Responding International',
          'INTERSTATE',
          'ICASE_Y1-CASE_Y1',
          'Case_IDNO-RESPONDINIT_CODE',
          CAST(A.Case_IDNO AS VARCHAR) + '-' + CAST(LTRIM(RTRIM(A.RESPONDINIT_CODE)) AS VARCHAR),
          COUNT (1),
          '1'
     FROM ICAS_Y1 A,
          CASE_Y1 B
    WHERE A.Case_IDNO = B.Case_IDNO
      AND IVDOutOfStateFips_CODE BETWEEN 'A' AND 'Z'
      AND A.RESPONDINIT_CODE = B.RESPONDINIT_CODE
      AND A.RespondInit_CODE = 'R'
    GROUP BY A.Case_IDNO,
             A.RESPONDINIT_CODE;

   SET @Ls_Sql_TEXT = 'EventGlobalSeq_NUMB should be in GLEV_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'EventGlobalSeq_NUMB should be in GLEV_Y1 table',
          'FINANCIAL',
          a.Table_NAME,
          'EventGlobalSeq_NUMB Count',
          a.SeqNumb_QNTY,
          a.SeqNumb_QNTY,
          '4'
     FROM (SELECT 'BCHK_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM BCHK_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'BHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM BHIS_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'BSUP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM BSUP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'STUB_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM STUB_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'CPFL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CPFL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'CHLD_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CHLD_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'CPNO_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CPNO_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DCRS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DCRS_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'DISH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DISH_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'DCKT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DCKT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'HDCKT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HDCKT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'DERR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DERR_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'EFTR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EFTR_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'ESEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ESEM_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'UNOT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM UNOT_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'GLEV_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM GLEV_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'PDIST_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PDIST_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'PESEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PESEM_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'PLEOM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PLEOM_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'PLSUP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PLSUP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'POBLE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM POBLE_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'PRREL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PRREL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'PRREP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PRREP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'IVMG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM IVMG_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DADR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DADR_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DSBL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DSBL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DEFT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DEFT_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DSBC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DSBC_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'DSBH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DSBH_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'DHLD_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DHLD_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'LSUP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM LSUP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'LWEL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM LWEL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'WELR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM WELR_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'MHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MHIS_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'HMHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HMHIS_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'OBLE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM OBLE_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'ORDB_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ORDB_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'POFL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM POFL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalSeq_NUMB)
           UNION ALL
           SELECT 'RCTH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RCTH_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'RBAT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RBAT_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'RCTR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RCTR_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'RECP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RECP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'SORD_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SORD_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'URCT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM URCT_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB)
           UNION ALL
           SELECT 'WEMO_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM WEMO_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEV_Y1 b
                               WHERE b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB) --UNION ALL
          ) a
    WHERE a.SeqNumb_QNTY > 0;

   SET @Ls_Sql_TEXT = 'TransactionEventSeq_NUMB should be in GLEC_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TransactionEventSeq_NUMB should be in GLEC_Y1 table',
          'NON-FINANCIAL',
          a.Table_NAME,
          'TransactionEventSeq Count',
          a.SeqNumb_QNTY,
          a.SeqNumb_QNTY,
          '4'
     FROM (SELECT 'ACEN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ACEN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ACES_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ACES_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'AHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM AHIS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HAHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HAHIS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APAH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APAH_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APCS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APCS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APCM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APCM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APDM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APDM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APEH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APEH_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'APMH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM APMH_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CASE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CASE_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HCASE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HCASE_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CJNR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CJNR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CMEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CMEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HCMEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HCMEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CRAS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CRAS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CWRK_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CWRK_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'COMP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM COMP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CPAF_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CPAF_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CBOR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CBOR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CAIN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CAIN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CSPR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CSPR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'UDEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM UDEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HUDEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HUDEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DINS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DINS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DPRS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DPRS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FDEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FDEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'EMRG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EMRG_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'EMLG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EMLG_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'EMQW_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EMQW_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'EHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EHIS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HEHIS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HEHIS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ELFC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ELFC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ASIG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ASIG_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FCRQ_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FCRQ_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FEDH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FEDH_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HFEDH_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HFEDH_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'GTST_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM GTST_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'GLEC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM GLEC_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PEMON_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PEMON_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PEWKL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PEWKL_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'IELFC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM IELFC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'IFMS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM IFMS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HIFMS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HIFMS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ISTX_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ISTX_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ICAS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ICAS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'RJCS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RJCS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'RJDT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RJDT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'IWEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM IWEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'LSTT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM LSTT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DMJR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DMJR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HDMJR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HDMJR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'AKAX_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM AKAX_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'BNKR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM BNKR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MECN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MECN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DEMO_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DEMO_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HDEMO_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HDEMO_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MDET_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MDET_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ASFN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ASFN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'INCM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM INCM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MINS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MINS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MMRG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MMRG_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MMLG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MMLG_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MPAT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MPAT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HMPAT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HMPAT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'MSSN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM MSSN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DMNR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DMNR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HDMNR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HDMNR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NOST_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NOST_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HNOST_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HNOST_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NOTE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NOTE_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NMRQ_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NMRQ_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NRRQ_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NRRQ_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'OTHP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM OTHP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'OTHX_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM OTHX_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PNCS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PNCS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PRCA_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PRCA_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PRDE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PRDE_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PRSO_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PRSO_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PNMB_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PNMB_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PLIC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PLIC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ASRE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ASRE_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ACRL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ACRL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'AFMS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM AFMS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SCAS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SCAS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CNRL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CNRL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'COPT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM COPT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'CSEP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM CSEP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DEBT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DEBT_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'DBTP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM DBTP_Y1 a
            WHERE NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'EMSG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM EMSG_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HEMSG_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HEMSG_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FFCL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FFCL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FIPS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FIPS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HIMS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HIMS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'PARM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM PARM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'LSRC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM LSRC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'REFM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM REFM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HREFM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HREFM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'AMJR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM AMJR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'AMNR_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM AMNR_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ANXT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ANXT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NREP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NREP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'NREF_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM NREF_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'OFIC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM OFIC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ROLE_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ROLE_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'RLSA_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RLSA_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SHOL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SHOL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SCFN_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SCFN_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'RSCL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM RSCL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'UCAT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM UCAT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'ASRV_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM ASRV_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SWKS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SWKS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HSWKS_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HSWKS_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SLSD_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SLSD_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SWRK_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SWRK_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'FSRT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM FSRT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'SLST_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM SLST_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'TEXC_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM TEXC_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'USES_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM USES_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HUSES_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HUSES_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'USEM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM USEM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'USRL_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM USRL_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'UASM_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM UASM_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'USRT_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM USRT_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'VAPP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM VAPP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB)
           UNION ALL
           SELECT 'HVAPP_Y1' AS Table_NAME,
                  COUNT(1) AS SeqNumb_QNTY
             FROM HVAPP_Y1 a
            WHERE WorkerUpdate_ID <> 'DECSS'
              AND NOT EXISTS (SELECT 1
                                FROM GLEC_Y1 b
                               WHERE b.TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB) --UNION ALL
          )a
    WHERE a.SeqNumb_QNTY > 0;

   SET @Ls_Sql_TEXT = 'Foster Care Case CP (IVMG.CpMci_IDNO) should be always 999998 - DIV FAMILY SERVICES';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Foster Care Case CP (IVMG.CpMci_IDNO) should be always 999998 - DIV FAMILY SERVICES',
          'FINANCIAL',
          'IVMG_Y1',
          'CaseWelfare_IDNO',
          CaseWelfare_IDNO,
          COUNT(1),
          '1'
     FROM IVMG_Y1
    WHERE WelfareElig_CODE = 'F'
      AND CpMci_IDNO <> 999998
    GROUP BY CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'Foster Care Case is not converted in IVMG Table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SELECT TOP 1 @Ln_CaseWelfare_IDNO = CaseWelfare_IDNO
     FROM IVMG_Y1
    WHERE WelfareElig_CODE = 'F'

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     INSERT CRIR_Y1
            (DescriptionError_TEXT,
             FunctionalArea_TEXT,
             Table_NAME,
             EntityType_TEXT,
             Entity_ID,
             ErrorCount_QNTY,
             Error_Severity_Code)
     SELECT 'Foster Care Case is not converted in IVMG Table',
            'FINANCIAL',
            'IVMG_Y1',
            'WelfareElig_CODE',
            'F',
            0,
            '1'
    END

   SET @Ls_Sql_TEXT = 'TANF Case is not converted in IVMG Table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   SELECT TOP 1 @Ln_CaseWelfare_IDNO = CaseWelfare_IDNO
     FROM IVMG_Y1
    WHERE WelfareElig_CODE = 'A'

   SET @Li_Rowcount_QNTY = @@ROWCOUNT;

   IF @Li_Rowcount_QNTY = 0
    BEGIN
     INSERT CRIR_Y1
            (DescriptionError_TEXT,
             FunctionalArea_TEXT,
             Table_NAME,
             EntityType_TEXT,
             Entity_ID,
             ErrorCount_QNTY,
             Error_Severity_Code)
     SELECT 'TANF Case is not converted in IVMG Table',
            'FINANCIAL',
            'IVMG_Y1',
            'WelfareElig_CODE',
            'A',
            0,
            '1'
    END

   SET @Ls_Sql_TEXT = 'TANF (MHIS) Case is not having supporting grant record in IVMG table for the Conversion Month';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TANF (MHIS) Case is not having supporting grant record in IVMG table for the Conversion Month',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'MemberMci_IDNO-Case_IDNO-Start_DATE-End_DATE-TypeWelfare_CODE-CaseWelfare_IDNO',
          CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Start_DATE AS VARCHAR) + '-' + CAST(a.End_DATE AS VARCHAR) + '-' + CAST(a.TypeWelfare_CODE AS VARCHAR) + '-' + CAST(a.CaseWelfare_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM MHIS_Y1 A
    WHERE TypeWelfare_CODE = 'A'
      AND @Ad_Conversion_DATE BETWEEN Start_DATE AND End_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IVMG_Y1 B
                       WHERE WelfareElig_CODE = 'A'
                         AND A.CaseWelfare_IDNO = B.CaseWelfare_IDNO
                         AND B.WelfareYearMonth_NUMB = CAST (CONVERT(VARCHAR(6), @Ad_Conversion_DATE, 112) AS NUMERIC(6)))
    GROUP BY CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Start_DATE AS VARCHAR) + '-' + CAST(a.End_DATE AS VARCHAR) + '-' + CAST(a.TypeWelfare_CODE AS VARCHAR) + '-' + CAST(a.CaseWelfare_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Foster care (MHIS) Case is not having supporting grant record in IVMG table for the Conversion Month';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Foster care (MHIS) Case is not having supporting grant record in IVMG table for the Conversion Month',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'MemberMci_IDNO-Case_IDNO-Start_DATE-End_DATE-TypeWelfare_CODE-CaseWelfare_IDNO',
          CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Start_DATE AS VARCHAR) + '-' + CAST(a.End_DATE AS VARCHAR) + '-' + CAST(a.TypeWelfare_CODE AS VARCHAR) + '-' + CAST(a.CaseWelfare_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM MHIS_Y1 A
    WHERE TypeWelfare_CODE = 'F'
      AND @Ad_Conversion_DATE BETWEEN Start_DATE AND End_DATE
      AND NOT EXISTS (SELECT 1
                        FROM IVMG_Y1 B
                       WHERE WelfareElig_CODE = 'F'
                         AND A.CaseWelfare_IDNO = B.CaseWelfare_IDNO
                         AND B.WelfareYearMonth_NUMB = CAST (CONVERT(VARCHAR(6), @Ad_Conversion_DATE, 112) AS NUMERIC(6)))
    GROUP BY CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Start_DATE AS VARCHAR) + '-' + CAST(a.End_DATE AS VARCHAR) + '-' + CAST(a.TypeWelfare_CODE AS VARCHAR) + '-' + CAST(a.CaseWelfare_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Multiple duplicate records are created in DMJR_Y1 for remedies';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Multiple duplicate records are created in DMJR_Y1 for remedies',
          'CASE MANAGEMENT',
          'DMJR_Y1',
          'Case_IDNO-ActivityMajor_CODE-Reference_ID',
          CAST(Case_IDNO AS VARCHAR) + '-' + ActivityMajor_CODE + '-' + Reference_ID,
          COUNT(1),
          '1'
     FROM DMJR_Y1
    WHERE Status_CODE = 'STRT'
      AND ActivityMajor_CODE NOT IN('AREN', 'GTST', 'CASE', 'MAPP', 'ESTP')
    GROUP BY Case_IDNO,
             ActivityMajor_CODE,
             Status_CODE,
             OthpSource_IDNO,
             Reference_ID
   HAVING COUNT(1) > 1;

   SET @Ls_Sql_TEXT = 'Scheduling is converted, But DMNR and DMJR corresponding entries are not converted';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Scheduling is converted, But DMNR and DMJR corresponding entries are not converted',
          'CASE MANAGEMENT',
          'SWKS_Y1',
          'Schedule_NUMB',
          CAST(s.Schedule_NUMB AS VARCHAR),
          COUNT(1),
          '1'
     FROM SWKS_Y1 s
    WHERE NOT EXISTS (SELECT 1
                        FROM DMNR_Y1 d
                       WHERE s.ActivityMajor_CODE = d.ActivityMajor_CODE
                         AND s.Case_IDNO = d.Case_IDNO
                         AND s.Schedule_NUMB = d.Schedule_NUMB
                         AND s.ActivityMinor_CODE = d.ActivityMinor_CODE)
    GROUP BY s.Schedule_NUMB;

   SET @Ls_Sql_TEXT = 'R.I (CASE_MHIS) Foster Care case in CASE_Y1 should have MHIS_Y1.TypeWelfare_CODE set to "F".';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CASE_MHIS) Foster Care case in CASE_Y1 should have MHIS_Y1.TypeWelfare_CODE set to "F".',
          'CI',
          'CASE_Y1',
          'Case_IDNO',
          CAST(C.Case_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM CASE_Y1 C,
          CMEM_Y1 CM
    WHERE C.Case_IDNO = CM.Case_IDNO
      AND CM.CaseRelationship_CODE = 'D'
      AND C.StatusCase_CODE = 'O'
      AND C.TypeCase_CODE = 'F'
      AND NOT EXISTS(SELECT 1
                       FROM MHIS_Y1 M
                      WHERE M.Case_IDNO = C.Case_IDNO
                        AND M.MemberMci_IDNO = CM.MemberMci_IDNO
                        AND C.TypeCase_CODE = M.TypeWelfare_CODE
                        AND @Ad_Conversion_DATE BETWEEN M.Start_DATE AND M.End_DATE)
    GROUP BY C.Case_IDNO,
             C.TypeCase_CODE;

   SET @Ls_Sql_TEXT = 'ICAS_Y1.IVDOutOfStateTypeCase_CODE is not valid';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ICAS_Y1.IVDOutOfStateTypeCase_CODE is not valid',
          'FIN',
          'ICAS_Y1',
          'IVDOutOfStateTypeCase_CODE',
          a.IVDOutOfStateTypeCase_CODE,
          COUNT(1),
          '2'
     FROM ICAS_Y1 a
    WHERE NOT EXISTS(SELECT 1
                       FROM REFM_Y1 b
                      WHERE b.Table_ID = 'CCRT'
                        AND b.TableSub_ID = 'CTYP'
                        AND b.Value_CODE = a.IVDOutOfStateTypeCase_CODE)
    GROUP BY a.IVDOutOfStateTypeCase_CODE;

   SET @Ls_Sql_TEXT = 'DEMO_Y1 should have first and last name';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DEMO_Y1 should have first and last name',
          'CI',
          'DEMO_Y1',
          'MemberMci_IDNO',
          CAST(d.MemberMci_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM DEMO_Y1 d
    WHERE d.First_NAME = ''
       OR d.Last_NAME = ''
    GROUP BY d.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'BHIS_Y1 should not have any data converted';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'BHIS_Y1 should not have any data converted',
          'FIN',
          'BHIS_Y1',
          'ErrorCount_NUMB',
          CAST(a.ErrorCount_NUMB AS VARCHAR),
          a.ErrorCount_NUMB,
          '2'
     FROM (SELECT COUNT(1) AS ErrorCount_NUMB
             FROM BHIS_Y1) a
    WHERE a.ErrorCount_NUMB > 1;

   SET @Ls_Sql_TEXT = 'BSUP_Y1 should not have any data converted';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'BSUP_Y1 should not have any data converted',
          'FIN',
          'BSUP_Y1',
          'ErrorCount_NUMB',
          CAST(a.ErrorCount_NUMB AS VARCHAR),
          a.ErrorCount_NUMB,
          '2'
     FROM (SELECT COUNT(1) AS ErrorCount_NUMB
             FROM BSUP_Y1) a
    WHERE a.ErrorCount_NUMB > 1;

   SET @Ls_Sql_TEXT = 'MINS_Y1.PolicyHolderRelationship_CODE should have "SF" or "OT" values';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MINS_Y1.PolicyHolderRelationship_CODE should have "SF" or "OT" values',
          'FIN',
          'MINS_Y1',
          'PolicyHolderRelationship_CODE',
          CAST(m.PolicyHolderRelationship_CODE AS VARCHAR),
          COUNT(1),
          '1'
     FROM MINS_Y1 m
    WHERE m.PolicyHolderRelationship_CODE NOT IN ('SF', 'OT')
    GROUP BY m.PolicyHolderRelationship_CODE;

   SET @Ls_Sql_TEXT = 'R.I.(UASM_USRL) UASM_Y1.Expire_DATE should match USRL_Y1.Expire_DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I.(UASM_USRL) UASM_Y1.Expire_DATE should match USRL_Y1.Expire_DATE' AS Reason,
          'SECURITY' AS Subsystem,
          'UASM_Y1',
          'Expire_DATE',
          CAST(a.Expire_DATE AS VARCHAR),
          COUNT(1),
          '2'
     FROM UASM_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM USRL_Y1 us
                   WHERE us.Worker_ID = a.Worker_ID
                     AND us.Expire_DATE > a.Expire_DATE
                     AND us.EndValidity_DATE > a.EndValidity_DATE)
    GROUP BY a.Expire_DATE;

   SET @Ls_Sql_TEXT = 'R.I.(USEM_USRL) USEM_Y1.EndValidity_DATE should match USRL_Y1.EndValidity_DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I.(USEM_USRL) USEM_Y1.EndValidity_DATE should match USRL_Y1.EndValidity_DATE' AS Reason,
          'SECURITY' AS Subsystem,
          'UASM_Y1',
          'Expire_DATE',
          CAST(a.EndValidity_DATE AS VARCHAR),
          COUNT(1),
          '2'
     FROM USEM_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM USRL_Y1 us
                   WHERE us.Worker_ID = a.Worker_ID
                     AND us.EndValidity_DATE > a.EndValidity_DATE)
    GROUP BY a.EndValidity_DATE;

   SET @Ls_Sql_TEXT = 'DINS_Y1.Status_DATE has Min date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DINS_Y1.Status_DATE has Min date' AS Reason,
          'FIN' AS Subsystem,
          'DINS_Y1',
          'Status_DATE',
          CAST(a.Status_DATE AS VARCHAR),
          COUNT(1),
          '3'
     FROM DINS_Y1 a
    WHERE a.Status_DATE = '0001-01-01'
    GROUP BY a.Status_DATE;

   SET @Ls_Sql_TEXT = 'CASE_Y1.RespondInit_CODE should set to "N" when the Case is Closed';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE_Y1.RespondInit_CODE should set to "N" when the Case is Closed',
          'CI' AS Subsystem,
          'CASE_Y1',
          'Case_IDNO',
          CAST(ca.Case_IDNO AS VARCHAR),
          COUNT(1),
          '1'
     FROM CASE_Y1 CA
    WHERE CA.StatusCase_CODE = 'C'
      AND RespondInit_CODE != 'N'
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'CASE_Y1.RespondInit_CODE should be set to "N" and no ICAS record must exist when case is Closed In CASE_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE_Y1.RespondInit_CODE should be set to "N" and no ICAS record must exist when case is Closed In CASE_Y1',
          'CI' AS Subsystem,
          'CASE_Y1',
          'Case_IDNO',
          CAST(ca.Case_IDNO AS VARCHAR),
          COUNT(1),
          '2'
     FROM CASE_Y1 CA
    WHERE CA.StatusCase_CODE = 'C'
      AND RespondInit_CODE = 'N'
      AND EXISTS(SELECT IC.Case_IDNO
                   FROM ICAS_Y1 IC
                  WHERE CA.Case_IDNO = IC.Case_IDNO)
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'Invalid combination Type FAMIS Proceeding Code and Scheduling Unit Code';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid combination Type FAMIS Proceeding Code and Scheduling Unit Code',
          'CM and ES',
          'SWKS_Y1',
          'Schedule_NUMB',
          Schedule_NUMB,
          COUNT(1),
          '2'
     FROM SWKS_Y1
    WHERE WorkerUpdate_ID = 'CONVERSION'
      AND ActivityMajor_CODE IN ('ROFO', 'MAPP', 'ESTP')
      AND TypeFamisProceeding_CODE != SchedulingUnit_CODE
      AND ((SchedulingUnit_CODE IN ('CO', 'JU', 'MS')
            AND TypeFamisProceeding_CODE NOT IN ('C', 'H', 'T', 'HT'))
            OR (SchedulingUnit_CODE = 'BT'
                AND TypeFamisProceeding_CODE NOT IN ('B', 'BT'))
            OR (SchedulingUnit_CODE = 'MA'
                AND TypeFamisProceeding_CODE NOT IN ('M', 'MT')))
    GROUP BY Schedule_NUMB;

   SET @Ls_Sql_TEXT = 'DMJR_Y1.ActivityMajor_CODE = LSNR then TypeReference_CODE and/or Reference_ID should not be blank and/or OthpSource_IDNO should not be 0';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DMJR_Y1.ActivityMajor_CODE = LSNR then TypeReference_CODE and/or Reference_ID should not be blank and/or OthpSource_IDNO should not be 0',
          'CI' AS Subsystem,
          'DMJR_Y1',
          'ActivityMajor_CODE - OthpSource_IDNO - TypeReference_CODE - Reference_ID',
          CAST((mj.ActivityMajor_CODE + ' - ' + CAST(mj.OthpSource_IDNO AS VARCHAR) + ' - ' + mj.TypeReference_CODE + ' - ' + mj.Reference_ID) AS VARCHAR),
          COUNT(1),
          '2'
     FROM DMJR_Y1 mj
    WHERE mJ.ActivityMajor_CODE = 'LSNR'
      AND Status_CODE <> 'EXMT'
      AND (mj.OthpSource_IDNO = 0
            OR mj.TypeReference_CODE = ''
            OR mj.Reference_ID = '')
    GROUP BY mJ.ActivityMajor_CODE,
             mj.OthpSource_IDNO,
             mj.TypeReference_CODE,
             mj.Reference_ID;

   SET @Ls_Sql_TEXT = 'For unidentified receipts distribute date should be LOWDATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'For unidentified receipts distribute date should be LOWDATE',
          'FIN',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT(1),
          '1'
     FROM RCTH_Y1
    WHERE StatusReceipt_CODE = 'U'
      AND distribute_date <> '01/01/0001'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'For HELD receipts distribute date should be LOWDATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'For HELD receipts distribute date should be LOWDATE',
          'FIN',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), h.Batch_DATE, 101) + '-' + h.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (h.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(h.SeqReceipt_NUMB)) + CAST(h.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(h.SeqReceipt_NUMB)) + CAST(h.SeqReceipt_NUMB AS VARCHAR)), 4, 3) AS Receipt_Key,
          COUNT(1),
          '1'
     FROM RCTH_Y1 h
    WHERE H.StatusReceipt_CODE = 'H'
      AND H.Distribute_DATE != '01/01/0001'
      AND H.Distribute_DATE = @Ad_Conversion_DATE
      AND NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 r
                       WHERE r.StatusReceipt_CODE = 'R'
                         AND R.Batch_DATE = h.BATCH_DATE
                         AND R.SourceBatch_CODE = h.SourceBatch_CODE
                         AND R.Batch_NUMB = h.Batch_NUMB
                         AND R.SeqReceipt_NUMB = h.SeqReceipt_NUMB
                         AND r.Distribute_DATE = h.Distribute_DATE)
    GROUP BY CONVERT (VARCHAR (MAX), h.Batch_DATE, 101) + '-' + h.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (h.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(h.SeqReceipt_NUMB)) + CAST(h.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(h.SeqReceipt_NUMB)) + CAST(h.SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'Disbursement Refund Pseudo receipt Status Code should be R, Distribute Date should be Conversion date and Release Date should be Conversion date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disbursement Refund Pseudo receipt Status Code should be R, Distribute Date should be Conversion date and Release Date should be Conversion date',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-StatusReceipt_CODE-Distribute_DATE-Release_DATE',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR) Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE B.StatusReceipt_CODE = 'R'
      AND a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND (B.Distribute_DATE <> @Ad_Conversion_DATE
            OR B.Release_DATE <> @Ad_Conversion_DATE)
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Disbursement Hold Pseudo Receipt Status Code should be I, Distribute Date should be Conversion date and Release Date should be Conversion date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disbursement Hold Pseudo Receipt Status Code should be I, Distribute Date should be Conversion date and Release Date should be Conversion date',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-StatusReceipt_CODE-Distribute_DATE-Release_DATE',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR) Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE TypeDisburse_CODE = 'XCONV'
      AND Status_CODE = 'H'
      AND a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND (b.StatusReceipt_CODE <> 'I'
            OR B.Distribute_DATE <> @Ad_Conversion_DATE
            OR B.Release_DATE <> @Ad_Conversion_DATE)
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Disb Refund Pseduo Receipt Status Code should be R Distribute Date should be Conversion date Release Date should be Conversion date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disb Refund Pseduo Receipt Status Code should be R Distribute Date should be Conversion date Release Date should be Conversion date',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-StatusReceipt_CODE-Distribute_DATE-Release_DATE',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR) Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE TypeDisburse_CODE = 'REFND'
      AND Status_CODE = 'H'
      AND a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND (b.StatusReceipt_CODE <> 'R'
            OR B.Distribute_DATE <> @Ad_Conversion_DATE
            OR B.Release_DATE <> @Ad_Conversion_DATE)
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + b.StatusReceipt_CODE + '-' + CAST(b.Distribute_DATE AS VARCHAR) + '-' + CAST(b.Release_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'LSUP_Y1.TypeRecord_CODE value should be O - Original Transaction Records';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSUP_Y1.TypeRecord_CODE value should be O - Original Transaction Records',
          'FINANCIAL',
          'LSUP_Y1',
          'TypeRecord_CODE',
          a.TypeRecord_CODE,
          COUNT (1),
          '1'
     FROM LSUP_Y1 a
    WHERE LTRIM(RTRIM (a.TypeRecord_CODE)) <> 'O'
    GROUP BY TypeRecord_CODE;

   SET @Ls_Sql_TEXT = 'Birth Date should be Low Date instead 12/31/9999 or 01/01/1900';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Birth Date should be Low Date instead 12/31/9999 or 01/01/1900',
          'CM',
          'DEMO_Y1',
          'MemberMci_IDNO-Birth_DATE',
          CAST(MemberMci_IDNO AS VARCHAR) + ' - ' + CAST(Birth_DATE AS VARCHAR),
          COUNT(1),
          '2'
     FROM DEMO_Y1
    WHERE WorkerUpdate_ID = 'CONVERSION'
      AND (Birth_DATE = '12/31/9999'
            OR Birth_DATE = '01/01/1900')
      AND MemberMci_IDNO NOT IN(999995, 999996, 999997, 999998)
    GROUP BY MemberMci_IDNO,
             Birth_DATE;

   SET @Ls_Sql_TEXT = 'R.I (CASE_UASM) Worker_ID and/or Office_IDNO mismatch';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (CASE_UASM) Worker_ID and/or Office_IDNO mismatch',
          'CM',
          'CASE_Y1',
          'Case_IDNO - Worker_ID - Office_IDNO',
          CAST(A.Case_IDNO AS VARCHAR) + ' - ' + RTRIM(a.Worker_ID) + ' - ' + CAST(a.Office_IDNO AS VARCHAR),
          COUNT(1),
          '2'
     FROM CASE_Y1 A
          LEFT JOIN UASM_Y1 B
           ON A.Worker_ID = B.Worker_ID
              AND A.Office_IDNO = B.Office_IDNO
    WHERE (B.Office_IDNO IS NULL
        OR B.Worker_ID IS NULL)
    GROUP BY A.Case_IDNO,
             a.Worker_ID,
             a.Office_IDNO;

   SET @Ls_Sql_TEXT = 'NOTE_Y1.EventGlobalSeq_NUMB IS CONVERTED AS 0 INSTEAD OF VALID VALUE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NOTE_Y1.EventGlobalSeq_NUMB IS CONVERTED AS 0 INSTEAD OF VALID VALUE',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Category_CODE',
          Category_CODE,
          COUNT (1),
          '4'
     FROM NOTE_Y1
    WHERE EventGlobalSeq_NUMB = 0
    GROUP BY Category_CODE;

   SET @Ls_Sql_TEXT = 'TANF CASE TYPE MISMATCH';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TANF CASE TYPE MISMATCH',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE TypeCase_CODE = 'A'
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 b,
                             CMEM_Y1 c
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND b.End_DATE > @Ad_Conversion_DATE
                         AND b.TypeWelfare_CODE IN ('A')
                         AND b.Case_IDNO = c.Case_IDNO
                         AND b.MemberMci_IDNO = c.MemberMci_IDNO
                         AND c.CaseRelationship_CODE = 'D')
      AND NOT EXISTS(SELECT 1
                       FROM DISH_Y1 b
                      WHERE a.Case_IDNO = b.CasePayorMci_IDNO
                        AND b.TypeHold_CODE = 'C'
                        AND Expiration_DATE > @Ad_Conversion_DATE
                        AND EndValidity_DATE = '12/31/9999')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'MHIS CP RECORD IS CONVERTED AS TANF WITHOUT DP TANF RECORD';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MHIS CP RECORD IS CONVERTED AS TANF WITHOUT DP TANF RECORD',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO-MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM MHIS_Y1 a,
          CMEM_Y1 b
    WHERE a.End_DATE > @Ad_Conversion_DATE
      AND a.TypeWelfare_CODE = 'A'
      AND a.Case_IDNO = b.Case_IDNO
      AND a.MemberMci_IDNO = b.MemberMci_IDNO
      AND b.CaseRelationship_CODE = 'C'
      AND NOT EXISTS (SELECT 1
                        FROM MHIS_Y1 c,
                             CMEM_Y1 d
                       WHERE a.Case_IDNO = c.Case_IDNO
                         AND c.End_DATE > @Ad_Conversion_DATE
                         AND c.TypeWelfare_CODE = 'A'
                         AND c.Case_IDNO = d.Case_IDNO
                         AND c.MemberMci_IDNO = d.MemberMci_IDNO
                         AND d.CaseRelationship_CODE = 'D')
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Duplicate record exists in IWEM_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Duplicate record exists in IWEM_Y1 table',
          'ENF',
          'IWEM_Y1',
          'Case_IDNO-IwnStatus_CODE-MemberMci_IDNO-OrderSeq_NUMB-OthpEmployer_IDNO',
          CAST(Case_IDNO AS VARCHAR) + '-' + CAST(IwnStatus_CODE AS VARCHAR) + '-' + CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(OrderSeq_NUMB AS VARCHAR) + '-' + CAST(OthpEmployer_IDNO AS VARCHAR),
          COUNT(1) Record_Count,
          '2'
     FROM IWEM_Y1
    WHERE End_DATE = '9999-12-31'
      AND EndValidity_DATE = '9999-12-31'
      AND IwnStatus_CODE = 'A'
    GROUP BY CAST(Case_IDNO AS VARCHAR) + '-' + CAST(IwnStatus_CODE AS VARCHAR) + '-' + CAST(MemberMci_IDNO AS VARCHAR) + '-' + CAST(OrderSeq_NUMB AS VARCHAR) + '-' + CAST(OthpEmployer_IDNO AS VARCHAR)
   HAVING COUNT(1) > 1;

   SET @Ls_Sql_TEXT = 'NULL Value in VAPP_Y1.NOTE_TEXT column';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NULL Value in VAPP_Y1.NOTE_TEXT column',
          'ESTABLISHMENT',
          'VAPP_Y1',
          'NOTE_TEXT',
          NOTE_TEXT,
          COUNT (1),
          '1'
     FROM VAPP_Y1
    WHERE CHARINDEX (CHAR(0), NOTE_TEXT) > 0
    GROUP BY NOTE_TEXT;

   SET @Ls_Sql_TEXT = 'MHIS DP WELFARE TYPE IS TANF BUT CASE TYPE IS NON-TANF';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'MHIS DP WELFARE TYPE IS TANF BUT CASE TYPE IS NON-TANF',
          'CASE MANAGEMENT',
          'CASE_Y1',
          'Case_IDNO',
          Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 a
    WHERE TypeCase_CODE <> 'A'
      AND EXISTS (SELECT 1
                    FROM MHIS_Y1 b,
                         CMEM_Y1 c
                   WHERE a.Case_IDNO = b.Case_IDNO
                     AND b.End_DATE > @Ad_Conversion_DATE
                     AND b.TypeWelfare_CODE IN ('A')
                     AND b.Case_IDNO = c.Case_IDNO
                     AND b.MemberMci_IDNO = c.MemberMci_IDNO
                     AND c.CaseRelationship_CODE = 'D')
    GROUP BY Case_IDNO;

   SET @Ls_Sql_TEXT = 'FDEM_Y1.File_ID should not be empty';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'FDEM_Y1.File_ID should not be empty' AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'FDEM_Y1' AS Table_NAME,
          'File_ID' AS EntityType_TEXT,
          CAST(Case_IDNO AS VARCHAR) AS ENTITY_ID,
          COUNT (1),
          '1' AS ErrorCount_QNTY
     FROM FDEM_Y1 a
    WHERE LTRIM(RTRIM(File_ID)) = ''
    GROUP BY CAST(a.Case_IDNO AS VARCHAR)

   SET @Ls_Sql_TEXT = 'DHLD Refund TypeDisburse_CODE should be REFND, Status_CODE should be H, TypeHold_CODE and Status_CODE columns should have appropriate values.';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DHLD Refund TypeDisburse_CODE should be REFND, Status_CODE should be H, TypeHold_CODE and Status_CODE columns should have appropriate values.',
          'FINANCIAL',
          'RCTH_Y1-DHLD_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-StatusReceipt_CODE-Distribute_DATE-Release_DATE',
          CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + a.TypeDisburse_CODE + '-' + a.Status_CODE Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a,
          RCTH_Y1 b
    WHERE B.StatusReceipt_CODE = 'R'
      AND a.EndValidity_DATE = '12/31/9999'
      AND a.Batch_DATE = b.Batch_DATE
      AND a.SourceBatch_CODE = b.SourceBatch_CODE
      AND a.Batch_NUMB = b.Batch_NUMB
      AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB
      AND b.EndValidity_DATE = '12/31/9999'
      AND (a.TypeDisburse_CODE <> 'REFND'
            OR a.Status_CODE <> 'H')
    GROUP BY CONVERT (VARCHAR (MAX), a.Batch_DATE, 101) + '-' + a.SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (a.Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(a.SeqReceipt_NUMB)) + CAST(a.SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + a.TypeDisburse_CODE + '-' + a.Status_CODE;

   SET @Ls_Sql_TEXT = 'Type Reference Code and Reference ID should be coverted with TypeLicense_CODE and LicenseNo_TEXT(PLIC_Y1) respectively form the selected source for the License Suspension and Non-Renewal activity';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Type Reference Code and Reference ID should be coverted with TypeLicense_CODE and LicenseNo_TEXT(PLIC_Y1) respectively form the selected source for the License Suspension and Non-Renewal activity',
          'ENF',
          'DMJR_Y1',
          'Case_IDNO-OthpSource_IDNO-TypeReference_Code-Reference_ID',
          CAST(Case_IDNO AS VARCHAR) + '-' + CAST(OthpSource_IDNO AS VARCHAR) + '-' + CAST(TypeReference_Code AS VARCHAR) + '-' + CAST(Reference_ID AS VARCHAR),
          COUNT(1),
          '2'
     FROM DMJR_Y1
    WHERE ActivityMajor_CODE = 'LSNR'
      AND (Reference_ID = ' '
            OR TypeReference_CODE = ' ')
      AND Status_CODE = 'STRT'
    GROUP BY Case_IDNO,
             OthpSource_IDNO,
             TypeReference_Code,
             Reference_ID;

   SET @Ls_Sql_TEXT = 'Activity Major Code should exists in AMJR table and it should not be blank';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Activity Major Code should exists in AMJR table and it should not be blank',
          'CM',
          'DMJR_Y1',
          'ActivityMajor_CODE',
          'Activity Major Code - ' + ActivityMajor_CODE,
          COUNT(1),
          '1'
     FROM DMJR_Y1
    WHERE ActivityMajor_CODE NOT IN (SELECT ActivityMajor_CODE
                                       FROM AMJR_Y1)
    GROUP BY ActivityMajor_CODE

   SET @Ls_Sql_TEXT = 'WORKERS IN THE OPEN CASES(CASE_Y1) SHOULD HAVE VALID RECORD IN CWRK_Y1 AND USRL_Y1 TABLE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'WORKERS IN THE OPEN CASES(CASE_Y1) SHOULD HAVE VALID RECORD IN CWRK_Y1 AND USRL_Y1 TABLE',
          'CM',
          'USRL_Y1',
          'Expire_DATE AND  EndValidity_DATE',
          'CASE ID - ' + CAST(Case_IDNO AS VARCHAR) + 'Worker ID - ' + CAST(Worker_ID AS VARCHAR),
          COUNT(1),
          '1'
     FROM CASE_Y1 a
    WHERE StatusCase_CODE = 'O'
      AND Case_IDNO NOT IN (SELECT Case_IDNO
                              FROM CWRK_Y1 c,
                                   USRL_Y1 u
                             WHERE c.Worker_ID = u.Worker_ID
                               AND u.Role_ID = c.Role_ID
                               AND u.Office_IDNO = c.Office_IDNO
                               AND c.EndValidity_DATE = '12/31/9999'
                               AND u.EndValidity_DATE = '12/31/9999'
                               AND ((c.Expire_DATE > @Ad_Conversion_DATE)
                                     OR (c.Expire_DATE > DATEADD(D, 1, @Ad_Conversion_DATE))))
    GROUP BY Worker_ID,
             Case_IDNO;

   SET @Ls_Sql_TEXT = 'Source Verified code should exists in PLIC table if Status Code is CG';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Source Verified code should exists in PLIC table if Status Code is CG',
          'EN',
          'PLIC_Y1',
          'SourceVerified_CODE',
          'Status_CODE - ' + Status_CODE + ', SourceVerified_CODE - ' + SourceVerified_CODE,
          COUNT(1),
          '1'
     FROM PLIC_Y1
    WHERE Status_CODE = 'CG'
      AND SourceVerified_CODE = ''
    GROUP BY Status_CODE,
             SourceVerified_CODE

   SET @Ls_Sql_TEXT = 'Issue License Date should by valid date in PLIC table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Issue License Date should by valid date in PLIC table',
          'EN',
          'PLIC_Y1',
          'IssueLicense_DATE',
          'IssueLicense_DATE - ' + CAST(IssueLicense_DATE AS VARCHAR),
          COUNT(1),
          '2'
     FROM PLIC_Y1
    WHERE IssueLicense_DATE = '0001-01-01'
    GROUP BY IssueLicense_DATE

   SET @Ls_Sql_TEXT = 'Employer in Mins - should have EMPLOYERPAID_INDC as Y';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Employer in Mins - should have EMPLOYERPAID_INDC as Y',
          'EN',
          'MINS_Y1',
          'OthpEmployer_IDNO - EmployerPaid_INDC',
          CAST(a.OthpEmployer_IDNO AS VARCHAR) + ' - ' + a.EmployerPaid_INDC,
          COUNT(1),
          '3'
     FROM MINS_Y1 a
    WHERE a.OthpEmployer_IDNO > 0
      AND a.EmployerPaid_INDC = 'N'
    GROUP BY a.OthpEmployer_IDNO,
             a.EmployerPaid_INDC;

   SET @Ls_Sql_TEXT = 'Open MINS with employer_IDNO but no matching EHIS';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Open MINS with employer_IDNO but no matching EHIS',
          'EN',
          'MINS_Y1',
          'OthpEmployer_IDNO - MemberMci_IDNO',
          CAST(a.OthpEmployer_IDNO AS VARCHAR) + ' - ' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT(1),
          '2'
     FROM MINS_Y1 a
    WHERE a.OthpEmployer_IDNO > 0
      AND a.End_date > '11/01/2012'
      AND NOT EXISTS (SELECT 1
                        FROM EHIS_Y1 e
                       WHERE e.MemberMci_IDNO = a.MemberMci_IDNO
                         AND e.OthpPartyEmpl_IDNO = a.OthpEmployer_IDNO)
    GROUP BY a.OthpEmployer_IDNO,
             a.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'EHIS_Y1.EmployerPrime_INDC should set to "Y" when the EndEmployment_DATE is high date for latest employment.';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'EHIS_Y1.EmployerPrime_INDC should set to "Y" when the EndEmployment_DATE is high date for latest employment.',
          'EN',
          'EHIS_Y1',
          'MemberMci_IDNO-EmployerPrime_INDC',
          CAST(MemberMci_IDNO AS VARCHAR) + ' - ' + EmployerPrime_INDC,
          COUNT(1),
          '2'
     FROM (SELECT MemberMci_IDNO,
                  EmployerPrime_INDC,
                  ROW_NUMBER() OVER (PARTITION BY MemberMci_IDNO ORDER BY EmployerPrime_INDC DESC) RowCount_NUMB
             FROM EHIS_Y1 E
            WHERE E.EndEmployment_DATE = '9999-12-31') X
    WHERE RowCount_NUMB = 1
      AND EmployerPrime_INDC = 'N'
    GROUP BY MemberMci_IDNO,
             EmployerPrime_INDC
    ORDER BY MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (RCTH_Y1) RCTH_Y1 StatusReceipt_CODE IS EMPTY';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (RCTH_Y1) RCTH_Y1 StatusReceipt_CODE IS EMPTY',
          'FINANCIAL',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE StatusReceipt_CODE = ''
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'PreNote_DATE Not Matching With Conversion Date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'PreNote_DATE Not Matching With Conversion Date',
          'CASE MANAGEMENT',
          'EFTR_Y1',
          'CHECK_RECIPIENT',
          CheckRecipient_ID,
          COUNT (1),
          '1'
     FROM EFTR_Y1
    WHERE StatusEft_CODE = 'PP'
      AND PreNote_DATE <> @Ad_Conversion_DATE
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'Multiple Obligation exists in the same period';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Multiple Obligation exists in the same period',
          'FM',
          'OBLE_Y1',
          'Case_IDNO - OrderSeq_NUMB - MemberMci_IDNO - TypeDebt_CODE - BeginObligation_DATE - EndObligation_DATE',
          CAST(a.Case_IDNO AS VARCHAR) + ' - ' + CAST(a.OrderSeq_NUMB AS VARCHAR) + ' - ' + CAST(a.MemberMci_IDNO AS VARCHAR) + ' - ' + a.TypeDebt_CODE + ' - ' + CAST(a.BeginObligation_DATE AS VARCHAR) + ' - ' + CAST(a.EndObligation_DATE AS VARCHAR),
          COUNT(1),
          '1'
     FROM OBLE_Y1 a
    WHERE a.EndValidity_DATE = '12/31/9999'
    GROUP BY a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.MemberMci_IDNO,
             a.TypeDebt_CODE,
             a.BeginObligation_DATE,
             a.EndObligation_DATE
   HAVING COUNT(1) > 1

   SET @Ls_Sql_TEXT = 'USRL_Y1.AlphaRangeFrom_CODE and USRL_Y1.AlphaRangeTo_CODE column length should be 3';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'USRL_Y1.AlphaRangeFrom_CODE and USRL_Y1.AlphaRangeTo_CODE column length should be 3',
          'EN',
          'USRL_Y1',
          'AlphaRangeFrom_CODE-AlphaRangeTo_CODE',
          CAST(AlphaRangeFrom_CODE AS VARCHAR) + ' - ' + AlphaRangeTo_CODE,
          COUNT(1),
          '2'
     FROM (SELECT AlphaRangeFrom_CODE,
                  AlphaRangeTo_CODE
             FROM USRL_Y1
            WHERE LEN(AlphaRangeFrom_CODE) > 3
               OR LEN(AlphaRangeTo_CODE) > 3) AS X
    GROUP BY AlphaRangeFrom_CODE,
             AlphaRangeTo_CODE;

   SET @Ls_Sql_TEXT = 'Referral Source and Referral Date missing for TANF, Medicaid, and Foster Care cases';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Referral Source and Referral Date missing for TANF, Medicaid, and Foster Care cases',
          'CM',
          'CASE_Y1',
          'CASE - Case Type - Case Category - Referral Source - Referral Date',
          CAST(Case_IDNO AS VARCHAR) + '-' + CAST(TypeCase_CODE AS VARCHAR) + '-' + CAST(CaseCategory_CODE AS VARCHAR) + '-' + CAST(SourceRfrl_CODE AS VARCHAR) + '-' + CAST(Referral_DATE AS VARCHAR),
          COUNT(1),
          '3'
     FROM CASE_Y1
    WHERE (TypeCase_CODE IN ('F', 'A')
            OR CaseCategory_CODE = 'MO')
      AND (SourceRfrl_CODE = ' '
            OR Referral_DATE = '01-01-0001')
    GROUP BY Case_IDNO,
             TypeCase_CODE,
             CaseCategory_CODE,
             SourceRfrl_CODE,
             Referral_DATE;

   SET @Ls_Sql_TEXT = 'Converted DSBH_Y1.Check_NUMB should be less than 20000000';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Converted DSBH_Y1.Check_NUMB should be less than 20000000',
          'FN',
          'DSBH_Y1',
          'CheckRecipient_ID-CheckRecipient_CODE-Disburse_DATE-DisburseSeq_NUMB-Check_NUMB',
          CheckRecipient_ID + '-' + CheckRecipient_CODE + '-' + CAST(Disburse_DATE AS VARCHAR) + '-' + CAST(DisburseSeq_NUMB AS VARCHAR) + ' - ' + CAST(Check_NUMB AS VARCHAR),
          COUNT(1),
          '1'
     FROM DSBH_Y1 A,
          GLEV_Y1 B
    WHERE MediumDisburse_CODE = 'C'
      AND A.Check_NUMB > 20000000
      AND A.EventGlobalBeginSeq_NUMB = B.EventGlobalSeq_NUMB
      AND Worker_ID <> 'BATCH'
    GROUP BY CheckRecipient_ID + '-' + CheckRecipient_CODE + '-' + CAST(Disburse_DATE AS VARCHAR) + '-' + CAST(DisburseSeq_NUMB AS VARCHAR) + ' - ' + CAST(Check_NUMB AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Invalid characters in the AlphaRangeFrom and AlphaRangeTo_CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid characters in the AlphaRangeFrom and AlphaRangeTo_CODE',
          'CM',
          'USRL_Y1',
          'AlphaRangeFrom_CODE - AlphaRangeTo_CODE',
          AlphaRangeFrom_CODE + ' - ' + AlphaRangeTo_CODE,
          COUNT(1),
          '3'
     FROM USRL_Y1
    WHERE LTRIM(RTRIM(AlphaRangeFrom_CODE)) LIKE '%[^A-Z]%'
       OR LTRIM(RTRIM(AlphaRangeTo_CODE)) LIKE '%[^A-Z]%'
    GROUP BY AlphaRangeFrom_CODE,
             AlphaRangeTo_CODE;

   SET @Ls_Sql_TEXT = 'AccountAssetNo_TEXT is required in ASFN when the verified status is good';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'AccountAssetNo_TEXT is required in ASFN when the verified status is good',
          'EN',
          'ASFN_Y1',
          'MemberMci_IDNO - OthpInsFin_IDNO - Asset_CODE',
          CAST(MemberMci_IDNO AS CHAR) + ' - ' + CAST(OthpInsFin_IDNO AS CHAR) + ' - ' + Asset_CODE,
          COUNT(1),
          '2'
     FROM ASFN_Y1
    WHERE AccountAssetNo_TEXT = ' '
      AND Status_CODE = 'Y'
      AND Asset_CODE IN ('01', '02', '03', '04',
                         '05', '06', '07', '08',
                         '09', '10', '11', '12',
                         '13', '14', '16', '17',
                         '18', '99', 'INS')
    GROUP BY MemberMci_IDNO,
             OthpInsFin_IDNO,
             Asset_CODE;

   SET @Ls_Sql_TEXT = 'Case Type A should be always linked to Category of FS (Full Services) or PA (Workable PFA) only';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Case Type A should be always linked to Category of FS (Full Services) or PA (Workable PFA) only',
          'CI',
          'CASE_Y1',
          'Case_IDNO - TypeCase_CODE - CaseCategory_CODE',
          CAST(Case_IDNO AS VARCHAR) + ' - ' + TypeCase_CODE + ' - ' + CaseCategory_CODE,
          COUNT(1),
          '2'
     FROM CASE_Y1
    WHERE TypeCase_CODE = 'A'
      AND CaseCategory_CODE NOT IN ('FS', 'PA')
    GROUP BY Case_IDNO,
             TypeCase_CODE,
             CaseCategory_CODE;

   SET @Ls_Sql_TEXT = 'Case is a Medicaid Only case but there are no corresponding MHIS records with program type of M';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Case is a Medicaid Only case but there are no corresponding MHIS records with program type of M',
          'CI',
          'CASE_Y1',
          'Case_IDNO - StatusCase_CODE - TypeCase_CODE - CaseCategory_CODE',
          CAST(Case_IDNO AS VARCHAR) + ' - ' + StatusCase_CODE + ' - ' + TypeCase_CODE + ' - ' + CaseCategory_CODE,
          COUNT(1),
          '1'
     FROM CASE_Y1 A
    WHERE a.CaseCategory_CODE = 'MO'
      AND NOT EXISTS (SELECT *
                        FROM MHIS_Y1 b
                       WHERE a.Case_IDNO = b.Case_IDNO
                         AND b.TypeWelfare_CODE = 'M')
    GROUP BY Case_IDNO,
             StatusCase_CODE,
             TypeCase_CODE,
             CaseCategory_CODE;

   SET @Ls_Sql_TEXT = 'CASE WORKER should have valid UASM profile record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE WORKER should have valid UASM profile record' ErrorDescription,
          'CM' Subsystem,
          'CASE_Y1' Table_name,
          'Worker_ID' AS ColumnName,
          Worker_ID,
          COUNT(1) CaseCount,
          1 Severity
     FROM CASE_Y1
    WHERE WORKER_ID NOT IN (SELECT Worker_ID
                              FROM UASM_Y1
                             WHERE Expire_DATE = '9999-12-31'
                               AND EndValidity_DATE = '9999-12-31')
      AND StatusCase_CODE = 'O'
    GROUP BY WORKER_ID;

   SET @Ls_Sql_TEXT = 'CASE WORKER should have valid USEM profile record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'CASE WORKER should have valid USEM profile record' ErrorDescription,
          'CM' Subsystem,
          'CASE_Y1' Table_name,
          'Worker_ID' AS ColumnName,
          Worker_ID,
          COUNT(1) CaseCount,
          1 Severity
     FROM CASE_Y1
    WHERE WORKER_ID NOT IN (SELECT Worker_ID
                              FROM USEM_Y1
                             WHERE EndEmployment_DATE = '9999-12-31'
                               AND EndValidity_DATE = '9999-12-31')
      AND StatusCase_CODE = 'O'
    GROUP BY Worker_ID;

   SET @Ls_Sql_TEXT = 'NO valid USEM_Y1 record for the Valid USRL_Y1 records';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NO valid USEM_Y1 record for the Valid USRL_Y1 records',
          'SEC',
          'USRL_Y1',
          'Worker_ID',
          Worker_ID,
          COUNT(1),
          '1' AS severity
     FROM USRL_Y1
    WHERE Worker_ID NOT IN (SELECT Worker_ID
                              FROM USEM_Y1
                             WHERE @Ad_Conversion_DATE BETWEEN BeginEmployment_DATE AND EndEmployment_DATE
                               AND EndValidity_DATE = '9999-12-31')
      AND GETDATE() BETWEEN Effective_DATE AND Expire_DATE
      AND EndValidity_DATE = '9999-12-31'
    GROUP BY Worker_ID;

   SET @Ls_Sql_TEXT = 'NO valid USEM_Y1 record for the Valid UASM_Y1 records';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'NO valid USEM_Y1 record for the Valid UASM_Y1 records',
          'SEC',
          'UASM_Y1',
          'Worker_ID',
          Worker_ID,
          COUNT(1),
          '1' AS severity
     FROM UASM_Y1
    WHERE Worker_ID NOT IN (SELECT Worker_ID
                              FROM USEM_Y1
                             WHERE @Ad_Conversion_DATE BETWEEN BeginEmployment_DATE AND EndEmployment_DATE
                               AND EndValidity_DATE = '9999-12-31')
      AND GETDATE() BETWEEN Effective_DATE AND Expire_DATE
      AND EndValidity_DATE = '9999-12-31'
    GROUP BY Worker_ID;

   SET @Ls_Sql_TEXT = 'SWRK should have record for each valid USEM profile record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'SWRK should have record for each valid USEM profile record',
          'CM',
          'SWRK_Y1',
          'Worker_ID',
          Worker_ID,
          COUNT(1),
          '2' AS severity
     FROM USEM_Y1
    WHERE EndValidity_DATE = '12/31/9999'
      AND Worker_ID NOT IN (SELECT Worker_ID
                              FROM SWRK_Y1
                             WHERE EndValidity_DATE = '12/31/9999')
      AND WorkerUpdate_ID = 'CONVERSION'
    GROUP BY Worker_ID;

   SET @Ls_Sql_TEXT = 'USEM should have valid profile for each SWRK record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'USEM should have valid profile for each SWRK record',
          'CM',
          'USEM_Y1',
          'Worker_ID',
          Worker_ID,
          COUNT(1),
          '2' AS severity
     FROM SWRK_Y1
    WHERE EndValidity_DATE = '12/31/9999'
      AND Worker_ID NOT IN (SELECT Worker_ID
                              FROM USEM_Y1
                             WHERE EndValidity_DATE = '12/31/9999')
      AND WorkerUpdate_ID = 'CONVERSION'
    GROUP BY Worker_ID;

   SET @Ls_Sql_TEXT = 'Held Receipt should have valid ReasonStatus_CODE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Held Receipt should have valid ReasonStatus_CODE',
          'FINANCIAL',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM RCTH_Y1
    WHERE StatusReceipt_CODE = 'H'
      AND LTRIM (RTRIM(ReasonStatus_CODE)) = ''
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'USEM_Y1.WorkerTitle_CODE column should not be empty';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'USEM_Y1.WorkerTitle_CODE column should not be empty',
          'FIN',
          'USEM_Y1',
          'WorkerTitle_CODE',
          CAST(WorkerTitle_CODE AS VARCHAR),
          COUNT(1),
          '2'
     FROM (SELECT WorkerTitle_CODE
             FROM USEM_Y1
            WHERE WorkerTitle_CODE = '') AS X
    GROUP BY WorkerTitle_CODE;

   SET @Ls_Sql_TEXT = 'UASM_Y1.WorkPhone_NUMB column should contain valid phone number';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'UASM_Y1.WorkPhone_NUMB column should contain valid phone number',
          'FIN',
          'UASM_Y1',
          'WorkPhone_NUMB',
          CAST(WorkPhone_NUMB AS VARCHAR),
          COUNT(1),
          '2'
     FROM (SELECT WorkPhone_NUMB
             FROM UASM_Y1
            WHERE LEN(WorkPhone_NUMB) != 10) AS X
    GROUP BY WorkPhone_NUMB;

   SET @Ls_Sql_TEXT = 'DMNR Status_DATE should be the completion date when the Status_CODE is COMP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DMNR Status_DATE should be the completion date when the Status_CODE is COMP',
          'EN',
          'DMNR_Y1',
          'Case_IDNO - ActivityMajor_CODE - Status_CODE - Status_DATE',
          CAST(Case_IDNO AS CHAR(6)) + ' - ' + ActivityMajor_CODE + ' - ' + Status_CODE + ' - ' + CAST(Status_DATE AS CHAR),
          COUNT(1),
          '2'
     FROM DMNR_Y1
    WHERE Status_CODE = 'COMP'
      AND Status_DATE = '12/31/9999'
    GROUP BY Case_IDNO,
             ActivityMajor_CODE,
             Status_CODE,
             Status_DATE;

   SET @Ls_Sql_TEXT = 'Cases with support order but still have PF and TypeDebt_CODE is not GT';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Cases with support order but still have PF and TypeDebt_CODE is not GT',
          'FINANCIAL',
          'CASE_Y1',
          'Case_IDNO-TypeDebt_CODE',
          CAST(a.Case_IDNO AS VARCHAR) + '-' + o.TypeDebt_CODE,
          COUNT(1),
          '3'
     FROM CASE_Y1 a,
          CMEM_Y1 b,
          OBLE_Y1 o
    WHERE a.Case_IDNO = b.Case_IDNO
      AND a.StatusCase_CODE = 'O'
      AND b.CaseRelationship_CODE = 'P'
      AND b.CaseMemberStatus_CODE = 'A'
      AND a.Case_IDNO = o.Case_IDNO
      AND o.TypeDebt_CODE != 'GT'
      AND EXISTS (SELECT 1
                    FROM SORD_Y1 s
                   WHERE s.Case_IDNO = a.Case_IDNO
                     AND s.EndValidity_DATE = '12/31/9999')
    GROUP BY a.Case_IDNO,
             o.TypeDebt_CODE;

   SET @Ls_Sql_TEXT = 'RI (SLST_RCTH) - SLST_Y1.SubmitLast_DATE should not be greater than RCTH_Y1.Receipt_DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RI (SLST_RCTH) - SLST_Y1.SubmitLast_DATE should not be greater than RCTH_Y1.Receipt_DATE',
          'FINANCIAL',
          'SLST_RCTH',
          'MemberMci_IDNO-SubmitLast_DATE-Receipt_DATE',
          x.Entity_ID,
          x.ErrorCount_QNTY,
          '2'
     FROM (SELECT CAST(s.MemberMci_IDNO AS VARCHAR) + '-' + CAST(s.SubmitLast_DATE AS VARCHAR) + '-' + CAST(r.Receipt_DATE AS VARCHAR) AS Entity_ID,
                  COUNT(1)AS ErrorCount_QNTY,
                  COUNT(1) OVER () AS TotalRecords
             FROM SLST_Y1 s,
                  RCTH_Y1 r
            WHERE r.SourceReceipt_CODE = 'ST'
              AND r.StatusReceipt_CODE = 'H'
              AND r.EndValidity_DATE = '12/31/9999'
              AND r.PayorMCI_IDNO = s.MemberMci_IDNO
              AND s.SubmitLast_DATE > r.Receipt_DATE
            GROUP BY s.MemberMci_IDNO,
                     s.SubmitLast_DATE,
                     r.Receipt_DATE) x
    WHERE x.TotalRecords > 25;

   SET @Ls_Sql_TEXT = 'TaxYear_NUMB should set to one year prior to the Year of SubmitLast_DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'TaxYear_NUMB should set to one year prior to the Year of SubmitLast_DATE',
          'FINANCIAL',
          'IFMS_Y1',
          'TaxYear_NUMB',
          CAST(a.TaxYear_NUMB AS VARCHAR),
          COUNT(1),
          '2'
     FROM IFMS_Y1 a
    WHERE a.TaxYear_NUMB >= DATEPART(YEAR, @Ad_Conversion_DATE)
    GROUP BY a.TaxYear_NUMB
   UNION ALL
   SELECT 'TaxYear_NUMB should set to one year prior to the Year of SubmitLast_DATE',
          'FINANCIAL',
          'ISTX_Y1',
          'TaxYear_NUMB',
          CAST(a.TaxYear_NUMB AS VARCHAR),
          COUNT(1),
          '2'
     FROM ISTX_Y1 a
    WHERE a.TaxYear_NUMB >= DATEPART(YEAR, @Ad_Conversion_DATE)
    GROUP BY a.TaxYear_NUMB
   UNION ALL
   SELECT 'TaxYear_NUMB should set to one year prior to the Year of SubmitLast_DATE',
          'FINANCIAL',
          'FEDH_Y1',
          'TaxYear_NUMB',
          CAST(a.TaxYear_NUMB AS VARCHAR),
          COUNT(1),
          '2'
     FROM FEDH_Y1 a
    WHERE a.TaxYear_NUMB >= DATEPART(YEAR, @Ad_Conversion_DATE)
    GROUP BY a.TaxYear_NUMB
   UNION ALL
   SELECT 'TaxYear_NUMB should set to one year prior to the Year of SubmitLast_DATE',
          'FINANCIAL',
          'SLST_Y1',
          'TaxYear_NUMB',
          CAST(a.TaxYear_NUMB AS VARCHAR),
          COUNT(1),
          '2'
     FROM SLST_Y1 a
    WHERE a.TaxYear_NUMB >= DATEPART(YEAR, @Ad_Conversion_DATE)
    GROUP BY a.TaxYear_NUMB;

   SET @Ls_Sql_TEXT = 'Foster Care cases should not have arrears in NA and PA buckets';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Foster Care cases should not have arrears in NA and PA buckets',
          'FIN',
          'MHIS_LSUP',
          'Case_IDNO-MemberMci_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB',
          CAST(m.Case_IDNO AS VARCHAR) + '-' + CAST(m.MemberMci_IDNO AS VARCHAR) + '-' + CAST(l.OrderSeq_NUMB AS VARCHAR) + '-' + CAST(l.ObligationSeq_NUMB AS VARCHAR),
          COUNT(1),
          '1'
     FROM MHIS_Y1 m,
          OBLE_Y1 o,
          LSUP_Y1 l
    WHERE m.TypeWelfare_CODE = 'F'
      AND @Ad_Conversion_DATE BETWEEN m.Start_DATE AND m.End_DATE
      AND m.Case_IDNO = o.Case_IDNO
      AND m.MemberMci_IDNO = o.MemberMci_IDNO
      AND o.TypeDebt_CODE != 'GT'
      AND o.Case_IDNO = l.Case_IDNO
      AND o.OrderSeq_NUMB = l.OrderSeq_NUMB
      AND o.ObligationSeq_NUMB = l.ObligationSeq_NUMB
      AND l.EventGlobalSeq_NUMB = (SELECT MAX(p.EventGlobalSeq_NUMB)
                                     FROM LSUP_Y1 p
                                    WHERE l.Case_IDNO = p.Case_IDNO
                                      AND l.OrderSeq_NUMB = p.OrderSeq_NUMB
                                      AND l.ObligationSeq_NUMB = p.ObligationSeq_NUMB
                                      AND l.SupportYearMonth_NUMB = p.SupportYearMonth_NUMB)
      AND (l.OweTotNaa_AMNT > 0
            OR l.OweTotPaa_AMNT > 0
            OR l.OweTotTaa_AMNT > 0
            OR l.OweTotCaa_AMNT > 0
            OR l.OweTotUpa_AMNT > 0
            OR l.OweTotUda_AMNT > 0
            OR l.OweTotMedi_AMNT > 0
            OR l.OweTotNffc_AMNT > 0
            OR l.OweTotNonIvd_AMNT > 0)
    GROUP BY m.Case_IDNO,
             m.MemberMci_IDNO,
             l.OrderSeq_NUMB,
             l.ObligationSeq_NUMB;

   SET @Ls_Sql_TEXT = 'ActivityMinorNext_CODE sould be populated with MPCOA';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ActivityMinorNext_CODE sould be populated with MPCOA',
          'EN',
          'DMNR_Y1',
          'Case_IDNO - ActivityMajor_CODE - ActivityMinor_CODE - ReasonStatus_CODE - ActivityMinorNext_CODE - Status_CODE',
          CAST(Case_IDNO AS CHAR) + ' - ' + ActivityMajor_CODE + ' - ' + ActivityMinor_CODE + ' - ' + ReasonStatus_CODE + ' - ' + ActivityMinorNext_CODE + ' - ' + Status_CODE,
          COUNT(1),
          '2'
     FROM DMNR_Y1
    WHERE Status_CODE = 'COMP'
      AND ActivityMajor_CODE != 'CASE'
      AND ActivityMinorNext_CODE = ''
      AND ActivityMinor_CODE != 'RMDCY'
    GROUP BY Case_IDNO,
             ActivityMajor_CODE,
             ActivityMinor_CODE,
             ReasonStatus_CODE,
             ActivityMinorNext_CODE,
             Status_CODE;

   SET @Ls_Sql_TEXT = 'Converted Hold Instructions from DACSES should have the effective date set to conversion date';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Converted Hold Instructions from DACSES should have the effective date set to conversion date',
          'FINANCIAL',
          'DISH_Y1',
          'CasePayorMCI_IDNO-Effective_DATE',
          CAST(CasePayorMCI_IDNO AS VARCHAR) + '-' + CAST(Effective_DATE AS VARCHAR),
          COUNT(1),
          '1'
     FROM DISH_Y1
    WHERE Effective_DATE != @Ad_Conversion_DATE
    GROUP BY CasePayorMCI_IDNO,
             Effective_DATE;

   SET @Ls_Sql_TEXT = 'Conversion System Hold Code should be changed from SDCV to MDCR in CHLD_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Conversion System Hold Code should be changed from SDCV to MDCR in CHLD_Y1',
          'FM',
          'CHLD_Y1',
          'ReasonHold_CODE',
          ReasonHold_CODE,
          COUNT(1),
          2
     FROM CHLD_Y1
    WHERE ReasonHold_CODE = 'SDCV'
    GROUP BY ReasonHold_CODE;

   SET @Ls_Sql_TEXT = 'Disbution Hold Expiration_DATE should be 120 days + Effective_DATE(Conversion Date)';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disbution Hold Expiration_DATE should be 120 days + Effective_DATE(Conversion Date)',
          'FM',
          'DISH_Y1',
          'Expiration_DATE',
          Expiration_DATE,
          COUNT(1) "Record Count",
          2 "Priority"
     FROM DISH_Y1
    WHERE Expiration_DATE = '12/31/9999'
    GROUP BY Expiration_DATE;

   SET @Ls_Sql_TEXT = 'Disbursement hold Expiration_DATE should be 90 days + Effective_DATE(Conversion Date)';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Disbursement hold Expiration_DATE should be 90 days + Effective_DATE(Conversion Date)',
          'FM',
          'CHLD_Y1',
          'Expiration_DATE',
          Expiration_DATE,
          COUNT(1)"Record Count",
          2 "Priority"
     FROM CHLD_Y1
    WHERE Expiration_DATE = '12/31/9999'
    GROUP BY Expiration_DATE;

   SET @Ls_Sql_TEXT = 'Invalid Address records in AHIS_Y1 – should not be converted if Zip, City, Address Line1 or State is space';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Invalid Address records in AHIS_Y1 – should not be converted if Zip, City, Address Line1 or State is space',
          'ENFORCEMENT' "subsystem",
          'AHIS_Y1' "Table",
          'MemberMci_IDNO-Address_Line_1-City-StateZip_ADDR' "Fields",
          CAST(a.MemberMci_IDNO AS VARCHAR) + '-' + LTRIM(RTRIM(Line1_ADDR)) + '-' + LTRIM(RTRIM(City_ADDR)) + '-' + LTRIM(RTRIM(State_ADDR)) + '-' + LTRIM(RTRIM(Zip_ADDR)) "MCI-Address_Line_1-City-State-Zip",
          COUNT (1) "Count",
          '2' "Priority"
     FROM AHIS_Y1 a
    WHERE Country_ADDR = 'US'
      AND (LTRIM(RTRIM(Zip_ADDR)) = ''
            OR LTRIM(RTRIM(Line1_ADDR)) = ''
            OR LTRIM(RTRIM(City_ADDR)) = ''
            OR LTRIM(RTRIM(State_ADDR)) = '')
      AND NOT EXISTS (SELECT 1
                        FROM AHIS_Y1 b
                       WHERE a.MemberMci_IDNO = b.MemberMci_IDNO
                         AND Country_ADDR = 'US'
                         AND Status_CODE = 'Y'
                         AND TypeAddress_CODE = 'M'
                         AND (LTRIM(RTRIM(Zip_ADDR)) <> ''
                              AND LTRIM(RTRIM(Line1_ADDR)) <> ''
                              AND LTRIM(RTRIM(City_ADDR)) <> ''
                              AND LTRIM(RTRIM(State_ADDR)) <> ''))
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 c,
                         CMEM_Y1 d
                   WHERE a.MemberMci_IDNO = a.MemberMci_IDNO
                     AND c.Case_IDNO = d.Case_IDNO
                     AND c.StatusCase_CODE = 'O')
    GROUP BY CAST(a.MemberMci_IDNO AS VARCHAR),
             LTRIM(RTRIM(Line1_ADDR)),
             LTRIM(RTRIM(City_ADDR)),
             LTRIM(RTRIM(State_ADDR)),
             LTRIM(RTRIM(Zip_ADDR));

   SET @Ls_Sql_TEXT = 'DISTIBUTED RECEIPT EXIST IN RCTH AND NOT IN LSUP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'DISTIBUTED RECEIPT EXIST IN RCTH AND NOT IN LSUP',
          'FINANCIAL',
          'RCTH_Y1-LSUP_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM RCTH_Y1 a
    WHERE a.Distribute_DATE <> '01/01/0001'
      AND a.EndValidity_DATE = '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM LSUP_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB)
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'ReasonStatus_CODE should be "OT"(OTHER) when StatusEnforce_code is E in ACEN_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'ReasonStatus_CODE should be "OT"(OTHER) when StatusEnforce_code is E in ACEN_Y1',
          'EN',
          'ACEN_Y1',
          'Case_IDNO - StatusEnforce_CODE - ReasonStatus_CODE',
          CAST(Case_IDNO AS CHAR(6)) + ' - ' + StatusEnforce_CODE + ' - ' + ReasonStatus_CODE,
          COUNT(1),
          2
     FROM ACEN_Y1
    WHERE StatusEnforce_CODE = 'E'
      AND ReasonStatus_CODE = 'CI'
    GROUP BY Case_IDNO,
             StatusEnforce_CODE,
             ReasonStatus_CODE

   SET @Ls_Sql_TEXT = 'When there is a case level exemption, DMJR records must be created with EXMT status for each Enforcement remedy except for CASE and AREN';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'When there is a case level exemption, DMJR records must be created with EXMT status for each Enforcement remedy except for CASE and AREN',
          'EN',
          'DMJR_Y1',
          'Case_IDNO - ActivityMajor_CODE',
          CAST(a.Case_IDNO AS CHAR(6)) + ' - ' + j.ActivityMajor_CODE,
          COUNT(1),
          2
     FROM AMJR_Y1 j,
          ACEN_Y1 a
    WHERE j.Subsystem_CODE = 'EN'
      AND j.ActivityMajor_CODE NOT IN ('AREN', 'CASE')
      AND a.StatusEnforce_CODE = 'E'
      AND j.EndValidity_DATE = '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 d
                       WHERE d.Case_IDNO = a.Case_IDNO
                         AND d.ActivityMajor_CODE = j.ActivityMajor_CODE
                         AND d.Status_CODE = 'EXMT'
                         AND d.BeginExempt_DATE <= a.EndExempt_DATE
                         AND d.EndExempt_DATE >= a.EndExempt_DATE)
    GROUP BY a.Case_IDNO,
             j.ActivityMajor_CODE
    ORDER BY a.Case_IDNO,
             j.ActivityMajor_CODE

   SET @Ls_Sql_TEXT = 'Held Disbursement Release Date should be HIGH DATE when CHLD record exists for CheckRecipient_ID';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Held Disbursement Release Date should be HIGH DATE when CHLD record exists for CheckRecipient_ID',
          'FINANCIAL',
          'DHLD_CHLD',
          'Unique_IDNO-Case_IDNO-CheckRecipient_ID-Release_DATE-TypeHold_CODE-ReasonStatus_CODE-TypeDisburse_CODE-Transaction_AMNT',
          CAST(Unique_IDNO AS VARCHAR) + '-' + RTRIM(Case_IDNO) + '-' + RTRIM(CheckRecipient_ID) + '-' + CAST(Release_DATE AS VARCHAR) + '-' + TypeHold_CODE + '-' + ReasonStatus_CODE + '-' + TypeDisburse_CODE + '-' + CAST(Transaction_AMNT AS VARCHAR),
          COUNT(1),
          1
     FROM DHLD_Y1 a
    WHERE Status_CODE = 'H'
      AND Release_DATE <> '12/31/9999'
      AND EndValidity_DATE = '9999-12-31'
      AND EXISTS (SELECT 1
                    FROM CHLD_Y1 b
                   WHERE ((a.CheckRecipient_CODE = '1'
                           AND a.CheckRecipient_ID = b.CheckRecipient_ID
                           AND a.CheckRecipient_CODE = b.CheckRecipient_CODE)
                           OR (a.CheckRecipient_CODE = '2'
                               AND b.CheckRecipient_CODE = '1'
                               AND b.CheckRecipient_ID = (SELECT c.MemberMci_IDNO
                                                            FROM CMEM_Y1 c
                                                           WHERE c.Case_IDNO = a.Case_IDNO
                                                             AND c.CaseRelationship_CODE = 'C'
                                                             AND CaseMemberStatus_CODE = 'A')))
                     AND b.EndValidity_DATE = '9999-12-31'
                     AND @Ad_Conversion_DATE BETWEEN b.Effective_DATE AND DATEADD (D, -1, b.Expiration_DATE))
    GROUP BY CAST(Unique_IDNO AS VARCHAR) + '-' + RTRIM(Case_IDNO) + '-' + RTRIM(CheckRecipient_ID) + '-' + CAST(Release_DATE AS VARCHAR) + '-' + TypeHold_CODE + '-' + ReasonStatus_CODE + '-' + TypeDisburse_CODE + '-' + CAST(Transaction_AMNT AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Held Disbursement is converted with Past Release Date in DHLD_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Held Disbursement is converted with Past Release Date in DHLD_Y1 table',
          'FINANCIAL',
          'DHLD',
          'Unique_IDNO-Case_IDNO-CheckRecipient_ID-Release_DATE-TypeHold_CODE-ReasonStatus_CODE-TypeDisburse_CODE-Transaction_AMNT',
          CAST(Unique_IDNO AS VARCHAR) + '-' + RTRIM(Case_IDNO) + '-' + RTRIM(CheckRecipient_ID) + '-' + CAST(Release_DATE AS VARCHAR) + '-' + TypeHold_CODE + '-' + ReasonStatus_CODE + '-' + TypeDisburse_CODE + '-' + CAST(Transaction_AMNT AS VARCHAR),
          COUNT(1),
          1
     FROM DHLD_Y1 d
    WHERE Status_CODE = 'H'
      AND Release_DATE <= @Ad_Conversion_DATE
      AND EndValidity_DATE = '9999-12-31'
    GROUP BY CAST(Unique_IDNO AS VARCHAR) + '-' + RTRIM(Case_IDNO) + '-' + RTRIM(CheckRecipient_ID) + '-' + CAST(Release_DATE AS VARCHAR) + '-' + TypeHold_CODE + '-' + ReasonStatus_CODE + '-' + TypeDisburse_CODE + '-' + CAST(Transaction_AMNT AS VARCHAR)

   SET @Ls_Sql_TEXT = 'Refund disbursements should be converted only for NCP check recipients';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Refund disbursements should be converted only for NCP check recipients',
          'FINANCIAL',
          'DHLD_Y1',
          'Case ID - CP Recipient ID',
          CAST(Case_IDNO AS VARCHAR) + '-' + CAST(CheckRecipient_ID AS VARCHAR),
          COUNT(1),
          '1'
     FROM DHLD_y1 d
    WHERE TypeDisburse_CODE = 'REFND'
      AND EndValidity_DATE = '12/31/9999'
      AND EXISTS (SELECT 1
                    FROM CMEM_Y1 c
                   WHERE c.Case_IDNO = d.Case_IDNO
                     AND d.CheckRecipient_ID = c.MemberMci_IDNO
                     AND c.CaseRelationship_CODE = 'C'
                     AND c.CaseMemberStatus_CODE = 'A')
    GROUP BY Case_IDNO,
             CheckRecipient_ID;

   SET @Ls_Sql_TEXT = 'WELFARE CASES ON IVMG WITH WelfareYearMonth_NUMB = 0';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'WELFARE CASES ON IVMG WITH WelfareYearMonth_NUMB = 0',
          'CASE MANAGEMENT',
          'IVMG_Y1',
          'CASE',
          CaseWelfare_IDNO,
          COUNT (1),
          '1'
     FROM IVMG_Y1 a
    WHERE WelfareYearMonth_NUMB = 0
    GROUP BY CaseWelfare_IDNO;

   SET @Ls_Sql_TEXT = 'LSTT_Y1.StatusLocate_CODE should be "Y" when confirmed good EHIS or AHIS for address of type mailing or residential exists';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'LSTT_Y1.StatusLocate_CODE should be "Y" when confirmed good EHIS or AHIS for address of type mailing or residential exists',
          'LOCATE',
          'LSTT_Y1',
          'MemberMci_IDNO - StatusLocate_CODE',
          CAST(l.MemberMci_IDNO AS VARCHAR) + ' - ' + l.StatusLocate_CODE,
          COUNT (1),
          '1'
     FROM LSTT_Y1 L
    WHERE StatusLocate_CODE = 'N'
      AND EndValidity_DATE = '9999-12-31'
      AND (EXISTS (SELECT 1
                     FROM EHIS_Y1 E
                    WHERE E.MemberMci_IDNO = L.MemberMci_IDNO
                      AND E.EndEmployment_DATE = L.EndValidity_DATE
                      AND Status_CODE = 'Y')
            OR EXISTS (SELECT 1
                         FROM AHIS_Y1 E
                        WHERE E.MemberMci_IDNO = L.MemberMci_IDNO
                          AND E.End_DATE = L.EndValidity_DATE
                          AND Status_CODE = 'Y'
                          AND TypeAddress_CODE IN ('M', 'R')))
    GROUP BY CAST(l.MemberMci_IDNO AS VARCHAR) + ' - ' + l.StatusLocate_CODE;

   SET @Ls_Sql_TEXT = 'AHIS not able to modify address';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'AHIS not able to modify address',
          'LOCATE',
          'AHIS_Y1',
          'MemberMci_IDNO - TypeAddress_CODE - Line1_ADDR - Line2_ADDR - City_ADDR - State_ADDR - Zip_ADDR',
          CAST(A.MemberMci_IDNO AS VARCHAR) + ' - ' + LTRIM(RTRIM(A.TypeAddress_CODE)) + ' - ' + LTRIM(RTRIM(A.Line1_ADDR)) + ' - ' + LTRIM(RTRIM(A.Line2_ADDR)) + ' - ' + LTRIM(RTRIM(A.City_ADDR)) + ' - ' + LTRIM(RTRIM(A.State_ADDR)) + ' - ' + LTRIM(RTRIM(A.Zip_ADDR)),
          COUNT (1),
          '1'
     FROM AHIS_Y1 A
    WHERE A.End_DATE = '9999-12-31'
    GROUP BY A.MemberMci_IDNO,
             A.TypeAddress_CODE,
             A.Line1_ADDR,
             A.Line2_ADDR,
             A.City_ADDR,
             A.State_ADDR,
             A.Zip_ADDR
   HAVING COUNT(DISTINCT(A.Status_CODE)) > 1;

   SET @Ls_Sql_TEXT = 'Held Receipt release date should  not be HIGH DATE';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Held Receipt release date should  not be HIGH DATE',
          'FINANCIAL',
          'RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB-ReasonStatus_CODE-Release_DATE',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + ReasonStatus_CODE + '-' + CAST(Release_DATE AS VARCHAR),
          COUNT (1),
          '1'
     FROM RCTH_Y1 A
    WHERE StatusReceipt_CODE = 'H'
      AND EndValidity_DATE = '12/31/9999'
      AND Release_DATE = '9999-12-31'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3) + '-' + ReasonStatus_CODE + '-' + CAST(Release_DATE AS VARCHAR);

   SET @Ls_Sql_TEXT = 'AHIS_Y1 - TransactionEventSeq_NUMB column number is not converted in assigning order';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'AHIS_Y1 - TransactionEventSeq_NUMB column number is not converted in assigning order',
          'CM',
          'AHIS_Y1',
          'MemberMci_IDNO',
          CAST(REC.MemberMci_IDNO AS CHAR(10)),
          COUNT(1),
          1
     FROM (SELECT Z.MEMBERMCI_IDNO,
                  Z.ROW_NUMB,
                  Z.ROW_NUMB1,
                  CASE
                   WHEN Z.ROW_NUMB = Z.ROW_NUMB1
                    THEN 'MATCH'
                   ELSE 'NO-MATCH'
                  END AS RESULT
             FROM (SELECT E.MEMBERMCI_IDNO,
                          ROW_NUMBER ()OVER ( PARTITION BY E.MEMBERMCI_IDNO ORDER BY E.TRANSACTIONEVENTSEQ_NUMB DESC) AS ROW_NUMB,
                          ROW_NUMBER ()OVER ( PARTITION BY E.MEMBERMCI_IDNO ORDER BY E.Begin_DATE DESC, E.TRANSACTIONEVENTSEQ_NUMB DESC) AS ROW_NUMB1
                     FROM AHIS_Y1 E) AS Z) AS REC
    WHERE REC.RESULT IN ('NO-MATCH')
    GROUP BY REC.MEMBERMCI_IDNO,
             REC.RESULT;

   SET @Ls_Sql_TEXT = 'EHIS_Y1 - TransactionEventSeq_NUMB column number is not converted in assigning order';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'EHIS_Y1 - TransactionEventSeq_NUMB column number is not converted in assigning order',
          'CM',
          'EHIS_Y1',
          'MemberMci_IDNO',
          CAST(REC.MemberMci_IDNO AS CHAR(10)),
          COUNT(1),
          1
     FROM (SELECT Z.MEMBERMCI_IDNO,
                  Z.ROW_NUMB,
                  Z.ROW_NUMB1,
                  CASE
                   WHEN Z.ROW_NUMB = Z.ROW_NUMB1
                    THEN 'MATCH'
                   ELSE 'NO-MATCH'
                  END AS RESULT
             FROM (SELECT E.MEMBERMCI_IDNO,
                          ROW_NUMBER ()OVER ( PARTITION BY E.MEMBERMCI_IDNO ORDER BY E.TRANSACTIONEVENTSEQ_NUMB DESC) AS ROW_NUMB,
                          ROW_NUMBER ()OVER ( PARTITION BY E.MEMBERMCI_IDNO ORDER BY E.BeginEmployment_DATE DESC, E.TRANSACTIONEVENTSEQ_NUMB DESC) AS ROW_NUMB1
                     FROM EHIS_Y1 E) AS Z) AS REC
    WHERE REC.RESULT IN ('NO-MATCH')
    GROUP BY REC.MEMBERMCI_IDNO,
             REC.RESULT;

   SET @Ls_Sql_TEXT = 'Obligation Base conversion record(EventFunctionalSeq_NUMB:9999)arrear amount is not matching with latest obligation record arrear amount in LSUP table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   ; WITH CNV_BaseRecord9999_Arrear_Tab
        AS (SELECT Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   ISNULL (((OweTotNaa_AMNT - AppTotNaa_AMNT) + (OweTotPaa_AMNT - AppTotPaa_AMNT) + (OweTotTaa_AMNT - AppTotTaa_AMNT) + (OweTotCaa_AMNT - AppTotCaa_AMNT) + (OweTotUpa_AMNT - AppTotUpa_AMNT) + (OweTotUda_AMNT - AppTotUda_AMNT) + (OweTotIvef_AMNT - AppTotIvef_AMNT) + (OweTotNffc_AMNT - AppTotNffc_AMNT) + (OweTotMedi_AMNT - AppTotMedi_AMNT) + (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT)), 0) Obligation_BaseRecord9999_Arrear_Amnt
              FROM LSUP_Y1 a
             WHERE a.SupportYearMonth_NUMB = (SELECT MAX (c.SupportYearMonth_NUMB)
                                                FROM LSUP_Y1 c
                                               WHERE c.Case_IDNO = a.Case_IDNO
                                                 AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                 AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                                 AND c.EventFunctionalSeq_NUMB = 9999)
               AND a.EventFunctionalSeq_NUMB = 9999
               AND a.EventGlobalSeq_NUMB = (SELECT MAX (EventGlobalSeq_NUMB)
                                              FROM LSUP_Y1 d
                                             WHERE d.Case_IDNO = a.Case_IDNO
                                               AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                               AND d.EventFunctionalSeq_NUMB = 9999
                                               AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                               AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB)),
        CNV_LatestRecord_Arrear_Tab
        AS (SELECT Case_IDNO,
                   OrderSeq_NUMB,
                   ObligationSeq_NUMB,
                   ISNULL (((OweTotNaa_AMNT - AppTotNaa_AMNT) + (OweTotPaa_AMNT - AppTotPaa_AMNT) + (OweTotTaa_AMNT - AppTotTaa_AMNT) + (OweTotCaa_AMNT - AppTotCaa_AMNT) + (OweTotUpa_AMNT - AppTotUpa_AMNT) + (OweTotUda_AMNT - AppTotUda_AMNT) + (OweTotIvef_AMNT - AppTotIvef_AMNT) + (OweTotNffc_AMNT - AppTotNffc_AMNT) + (OweTotMedi_AMNT - AppTotMedi_AMNT) + (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT)), 0) Obligation_LatestRecord_Arrear_Amnt
              FROM LSUP_Y1 a
             WHERE a.SupportYearMonth_NUMB = (SELECT MAX (c.SupportYearMonth_NUMB)
                                                FROM LSUP_Y1 c
                                               WHERE c.Case_IDNO = a.Case_IDNO
                                                 AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                 AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
               AND a.EventGlobalSeq_NUMB = (SELECT MAX (d.EventGlobalSeq_NUMB)
                                              FROM LSUP_Y1 d
                                             WHERE d.Case_IDNO = a.Case_IDNO
                                               AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                               AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                               AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB))
   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Obligation Base conversion record(EventFunctionalSeq_NUMB:9999)arrear amount is not matching with latest obligation record arrear amount in LSUP table'DescriptionError_TEXT,
          'FINANCIAL'FunctionalArea_TEXT,
          'LSUP_Y1'Table_NAME,
          'Case_IDNO:OrderSeq_NUMB:ObligationSeq_NUMB:Obligation_BaseRecord9999_Arrear_Amnt:Obligation_LatestRecord_Arrear_Amnt'EntityType_TEXT,
          CAST (Case_IDNO AS VARCHAR) + ':' + CAST (OrderSeq_NUMB AS VARCHAR) + ':' + CAST (ObligationSeq_NUMB AS VARCHAR) + ':' + CAST (Obligation_BaseRecord9999_Arrear_Amnt AS VARCHAR) + ':' + CAST (Obligation_LatestRecord_Arrear_Amnt AS VARCHAR)Entity_ID,
          COUNT (1)ErrorCount_QNTY,
          '1'Error_Severity_Code
     FROM (SELECT A.*,
                  B.Obligation_LatestRecord_Arrear_Amnt,
                  CASE
                   WHEN A.Obligation_BaseRecord9999_Arrear_Amnt = B.Obligation_LatestRecord_Arrear_Amnt
                    THEN 'Match'
                   ELSE 'Mismatch'
                  END AS ArrearMatch_Status
             FROM CNV_BaseRecord9999_Arrear_Tab a,
                  CNV_LatestRecord_Arrear_Tab b
            WHERE a.Case_IDNO = b.Case_IDNO
              AND a.OrderSeq_NUMB = b.OrderSeq_NUMB
              AND a.ObligationSeq_NUMB = B.ObligationSeq_NUMB) A
    WHERE ArrearMatch_Status = 'Mismatch'
    GROUP BY CAST (Case_IDNO AS VARCHAR) + ':' + CAST (OrderSeq_NUMB AS VARCHAR) + ':' + CAST (ObligationSeq_NUMB AS VARCHAR) + ':' + CAST (Obligation_BaseRecord9999_Arrear_Amnt AS VARCHAR) + ':' + CAST (Obligation_LatestRecord_Arrear_Amnt AS VARCHAR);

   SET @Ls_Sql_TEXT = 'RECEIPT EXIST IN DHLD AND NOT IN LSUP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RECEIPT EXIST IN DHLD AND NOT IN LSUP',
          'FINANCIAL',
          'DHLD_Y1-LSUP_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM DHLD_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM LSUP_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'RECEIPT EXIST IN DSBL AND NOT IN LSUP';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RECEIPT EXIST IN DSBL AND NOT IN LSUP',
          'FINANCIAL',
          'DSBL_Y1-LSUP_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM DSBL_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM LSUP_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB)
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   SET @Ls_Sql_TEXT = 'RECEIPT EXIST IN DSBL_Y1 AND NOT IN RCTH_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'RECEIPT EXIST IN DSBL_Y1 AND NOT IN RCTH_Y1',
          'FINANCIAL',
          'DSBL_Y1-RCTH_Y1',
          'Batch_DATE-SourceBatch_CODE-Batch_NUMB-SeqReceipt_NUMB',
          CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3)Receipt_Key,
          COUNT (1),
          '1'
     FROM DSBL_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM RCTH_Y1 b
                       WHERE a.Batch_DATE = b.Batch_DATE
                         AND a.SourceBatch_CODE = b.SourceBatch_CODE
                         AND a.Batch_NUMB = b.Batch_NUMB
                         AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB)
    GROUP BY CONVERT (VARCHAR (MAX), Batch_DATE, 101) + '-' + SourceBatch_CODE + '-' + RIGHT ('0000' + CAST (Batch_NUMB AS VARCHAR), 4) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 1, 3) + '-' + SUBSTRING ((REPLICATE('0', 6 - LEN(SeqReceipt_NUMB)) + CAST(SeqReceipt_NUMB AS VARCHAR)), 4, 3);

   -----------------------------------------------------------------------------------------------------------------------------------------------------------
   -- Arrear amount is not carry forwarded correctly in LSUP table
   -- While creating 1820, 1030 conversion records, it didn’t carry forwarded previous record balance amount to current Records
   -- This query will give only mismatch records When LSUP arrear is not carry forwarded correctly.
   -----------------------------------------------------------------------------------------------------------------------------------------------------------
   IF OBJECT_ID('tempdb..#Lsup_Tab') IS NOT NULL
    BEGIN
     DROP TABLE #Lsup_Tab;
    END

   -- Note: Selecting all the case obligations which contains psudeo receipts from LSUP. Selected Records will be inserted in #Lsup_Tab table
   SELECT ROW_NUMBER() OVER(PARTITION BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB ORDER BY a.Case_IDNO, a.OrderSeq_NUMB, a.ObligationSeq_NUMB, EventGlobalSeq_NUMB ) AS Row_NUMB,
          CASE
           WHEN a.TransactionNaa_AMNT > 0
            THEN 'NAA'
           WHEN a.TransactionPaa_AMNT > 0
            THEN 'PAA'
           WHEN a.TransactionTaa_AMNT > 0
            THEN 'TAA'
           WHEN a.TransactionCaa_AMNT > 0
            THEN 'CAA'
           WHEN a.TransactionUpa_AMNT > 0
            THEN 'UPA'
           WHEN a.TransactionUda_AMNT > 0
            THEN 'UDA'
           WHEN a.TransactionIvef_AMNT > 0
            THEN 'IVEF'
           WHEN a.TransactionMedi_AMNT > 0
            THEN 'MEDI'
           WHEN a.TransactionNffc_AMNT > 0
            THEN 'NFFC'
           WHEN a.TransactionNonIvd_AMNT > 0
            THEN 'NONIVD'
           ELSE ''
          END AS Bucket_NAME,
          ISNULL((SELECT TOP 1 Receipt_AMNT
                    FROM RCTH_Y1 b
                   WHERE a.Batch_DATE = b.Batch_DATE
                     AND a.SourceBatch_CODE = b.SourceBatch_CODE
                     AND a.Batch_NUMB = b.Batch_NUMB
                     AND a.SeqReceipt_NUMB = b.SeqReceipt_NUMB), 0) Receipt_AMNT,
          a.*
     INTO #Lsup_Tab
     FROM LSUP_Y1 A
    WHERE --A.Case_IDNO = 100402 AND
    EXISTS (SELECT 1
              FROM LSUP_Y1 B,
                   GLEV_Y1 C
             WHERE A.Case_IDNO = B.Case_IDNO
               AND A.OrderSeq_NUMB = B.OrderSeq_NUMB
               AND A.ObligationSeq_NUMB = B.ObligationSeq_NUMB
               AND B.EventFunctionalSeq_NUMB = 1820
               AND B.EventGlobalSeq_NUMB = C.EventGlobalSeq_NUMB
               AND C.Worker_ID = 'CONVERSION')
    ORDER BY a.Case_IDNO,
             a.OrderSeq_NUMB,
             a.ObligationSeq_NUMB,
             EventGlobalSeq_NUMB

   SET @Ls_Sql_TEXT = 'Arrear amount is not carry forwarded correctly in LSUP table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Arrear amount is not carry forwarded correctly in LSUP table',
          'FINANCIAL',
          'LSUP_Y1',
          'Worker_ID_Process_ID-Case_IDNO-OrderSeq_NUMB-ObligationSeq_NUMB-EventGlobalSeq_NUMB-Derived_OweTot_AMNT-Converted_OweTot_AMNT-OweTot_AMNT_Status-Derived_AppTot_AMNT-Converted_AppTot_AMNT-OweApp_AMNT_Status',
          Worker_ID_Process_ID + '-' + CAST(Case_IDNO AS VARCHAR) + '-' + CAST(OrderSeq_NUMB AS VARCHAR) + '-' + CAST(ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(EventGlobalSeq_NUMB AS VARCHAR) + '-' + CAST(Derived_OweTot_AMNT AS VARCHAR) + '-' + CAST(Converted_OweTot_AMNT AS VARCHAR) + '-' + CAST(OweTot_AMNT_Status AS VARCHAR) + '-' + CAST(Derived_AppTot_AMNT AS VARCHAR) + '-' + CAST(Converted_AppTot_AMNT AS VARCHAR) + '-' + CAST(OweApp_AMNT_Status AS VARCHAR),
          COUNT (1),
          '1'
     FROM (SELECT *
             FROM (SELECT ISNULL((SELECT RTRIM(Worker_ID) + '-' + RTRIM(Process_ID)
                                    FROM GLEV_Y1 d
                                   WHERE b.EventGlobalSeq_NUMB = d.EventGlobalSeq_NUMB), '') Worker_ID_Process_ID,
                          CASE
                           WHEN Derived_OweTot_AMNT <> Converted_OweTot_AMNT
                            THEN 'Mismatch'
                           ELSE 'Match'
                          END AS OweTot_AMNT_Status,
                          CASE
                           WHEN Derived_AppTot_AMNT <> Converted_AppTot_AMNT
                            THEN 'Mismatch'
                           ELSE 'Match'
                          END AS OweApp_AMNT_Status,
                          *
                     FROM (SELECT a.EventFunctionalSeq_NUMB EventFunctionalSeq_NUMB_1,
                                  CASE
                                   WHEN a.EventFunctionalSeq_NUMB = 1030
                                    THEN a.Base_OweTot_AMNT + a.Derived_Receipt_Amnt
                                   ELSE a.Base_OweTot_AMNT + Derived_Prev_Receipt_Amnt
                                  END AS Derived_OweTot_AMNT,
                                  CASE
                                   WHEN a.Bucket_NAME = 'NAA'
                                    THEN OweTotNaa_AMNT
                                   WHEN a.Bucket_NAME = 'PAA'
                                    THEN OweTotPaa_AMNT
                                   WHEN a.Bucket_NAME = 'TAA'
                                    THEN OweTotTaa_AMNT
                                   WHEN a.Bucket_NAME = 'CAA'
                                    THEN OweTotCaa_AMNT
                                   WHEN a.Bucket_NAME = 'UPA'
                                    THEN OweTotUpa_AMNT
                                   WHEN a.Bucket_NAME = 'UDA'
                                    THEN OweTotUda_AMNT
                                   WHEN a.Bucket_NAME = 'IVEF'
                                    THEN OweTotIvef_AMNT
                                   WHEN a.Bucket_NAME = 'MEDI'
                                    THEN OweTotMedi_AMNT
                                   WHEN a.Bucket_NAME = 'NFFC'
                                    THEN OweTotNffc_AMNT
                                   WHEN a.Bucket_NAME = 'NONIVD'
                                    THEN OweTotNonIvd_AMNT
                                   ELSE 0
                                  END AS Converted_OweTot_AMNT,
                                  CASE
                                   WHEN a.EventFunctionalSeq_NUMB = 1820
                                    THEN a.Base_AppTot_AMNT + a.Derived_Receipt_Amnt
                                   ELSE a.Base_AppTot_AMNT + Derived_Prev_Receipt_Amnt
                                  END AS Derived_AppTot_AMNT,
                                  CASE
                                   WHEN a.Bucket_NAME = 'NAA'
                                    THEN AppTotNaa_AMNT
                                   WHEN a.Bucket_NAME = 'PAA'
                                    THEN AppTotPaa_AMNT
                                   WHEN a.Bucket_NAME = 'TAA'
                                    THEN AppTotTaa_AMNT
                                   WHEN a.Bucket_NAME = 'CAA'
                                    THEN AppTotCaa_AMNT
                                   WHEN a.Bucket_NAME = 'UPA'
                                    THEN AppTotUpa_AMNT
                                   WHEN a.Bucket_NAME = 'UDA'
                                    THEN AppTotUda_AMNT
                                   WHEN a.Bucket_NAME = 'IVEF'
                                    THEN AppTotIvef_AMNT
                                   WHEN a.Bucket_NAME = 'MEDI'
                                    THEN AppTotMedi_AMNT
                                   WHEN a.Bucket_NAME = 'NFFC'
                                    THEN AppTotNffc_AMNT
                                   WHEN a.Bucket_NAME = 'NONIVD'
                                    THEN AppTotNonIvd_AMNT
                                   ELSE 0
                                  END AS Converted_AppTot_AMNT,
                                  *
                             FROM (SELECT ISNULL((SELECT CASE
                                                          WHEN cur.Bucket_NAME = 'NAA'
                                                           THEN OweTotNaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'PAA'
                                                           THEN OweTotPaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'TAA'
                                                           THEN OweTotTaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'CAA'
                                                           THEN OweTotCaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'UPA'
                                                           THEN OweTotUpa_AMNT
                                                          WHEN cur.Bucket_NAME = 'UDA'
                                                           THEN OweTotUda_AMNT
                                                          WHEN cur.Bucket_NAME = 'IVEF'
                                                           THEN OweTotIvef_AMNT
                                                          WHEN cur.Bucket_NAME = 'MEDI'
                                                           THEN OweTotMedi_AMNT
                                                          WHEN cur.Bucket_NAME = 'NFFC'
                                                           THEN OweTotNffc_AMNT
                                                          WHEN cur.Bucket_NAME = 'NONIVD'
                                                           THEN OweTotNonIvd_AMNT
                                                         END
                                                    FROM LSUP_Y1 B
                                                   WHERE cur.Case_IDNO = B.Case_IDNO
                                                     AND cur.OrderSeq_NUMB = B.OrderSeq_NUMB
                                                     AND cur.ObligationSeq_NUMB = B.ObligationSeq_NUMB
                                                     AND B.EventFunctionalSeq_NUMB = 9999), 0) Base_OweTot_AMNT,
                                          ISNULL((SELECT CASE
                                                          WHEN cur.Bucket_NAME = 'NAA'
                                                           THEN AppTotNaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'PAA'
                                                           THEN AppTotPaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'TAA'
                                                           THEN AppTotTaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'CAA'
                                                           THEN AppTotCaa_AMNT
                                                          WHEN cur.Bucket_NAME = 'UPA'
                                                           THEN AppTotUpa_AMNT
                                                          WHEN cur.Bucket_NAME = 'UDA'
                                                           THEN AppTotUda_AMNT
                                                          WHEN cur.Bucket_NAME = 'IVEF'
                                                           THEN AppTotIvef_AMNT
                                                          WHEN cur.Bucket_NAME = 'MEDI'
                                                           THEN AppTotMedi_AMNT
                                                          WHEN cur.Bucket_NAME = 'NFFC'
                                                           THEN AppTotNffc_AMNT
                                                          WHEN cur.Bucket_NAME = 'NONIVD'
                                                           THEN AppTotNonIvd_AMNT
                                                         END
                                                    FROM LSUP_Y1 B
                                                   WHERE cur.Case_IDNO = B.Case_IDNO
                                                     AND cur.OrderSeq_NUMB = B.OrderSeq_NUMB
                                                     AND cur.ObligationSeq_NUMB = B.ObligationSeq_NUMB
                                                     AND B.EventFunctionalSeq_NUMB = 9999), 0) Base_AppTot_AMNT,
                                          ISNULL((SELECT SUM(Prev.Receipt_AMNT)
                                                    FROM #Lsup_Tab prev
                                                   WHERE cur.Case_IDNO = prev.Case_IDNO
                                                     AND cur.OrderSeq_NUMB = prev.OrderSeq_NUMB
                                                     AND cur.ObligationSeq_NUMB = prev.ObligationSeq_NUMB
                                                     AND prev.EventFunctionalSeq_NUMB = 1820
                                                     AND ((cur.Row_NUMB = 2
                                                           AND prev.Row_NUMB = cur.Row_NUMB)
                                                           OR (cur.Row_NUMB > 2
                                                               AND prev.Row_NUMB <= cur.Row_NUMB))), 0) Derived_Receipt_Amnt,
                                          ISNULL((SELECT SUM(Prev.Receipt_AMNT)
                                                    FROM #Lsup_Tab prev
                                                   WHERE cur.Case_IDNO = prev.Case_IDNO
                                                     AND cur.OrderSeq_NUMB = prev.OrderSeq_NUMB
                                                     AND cur.ObligationSeq_NUMB = prev.ObligationSeq_NUMB
                                                     AND prev.EventFunctionalSeq_NUMB = 1820
                                                     AND prev.Row_NUMB < cur.Row_NUMB), 0) Derived_Prev_Receipt_Amnt,
                                          cur.*
                                     FROM #Lsup_Tab cur
                                          LEFT JOIN #Lsup_Tab prev
                                           ON cur.Case_IDNO = prev.Case_IDNO
                                              AND cur.OrderSeq_NUMB = prev.OrderSeq_NUMB
                                              AND cur.ObligationSeq_NUMB = prev.ObligationSeq_NUMB
                                              AND cur.Row_NUMB - 1 = prev.Row_NUMB) A)B)C
            WHERE (OweTot_AMNT_Status = 'Mismatch'
                OR OweApp_AMNT_Status = 'Mismatch'))D
    GROUP BY Worker_ID_Process_ID + '-' + CAST(Case_IDNO AS VARCHAR) + '-' + CAST(OrderSeq_NUMB AS VARCHAR) + '-' + CAST(ObligationSeq_NUMB AS VARCHAR) + '-' + CAST(EventGlobalSeq_NUMB AS VARCHAR) + '-' + CAST(Derived_OweTot_AMNT AS VARCHAR) + '-' + CAST(Converted_OweTot_AMNT AS VARCHAR) + '-' + CAST(OweTot_AMNT_Status AS VARCHAR) + '-' + CAST(Derived_AppTot_AMNT AS VARCHAR) + '-' + CAST(Converted_AppTot_AMNT AS VARCHAR) + '-' + CAST(OweApp_AMNT_Status AS VARCHAR)

   SET @Ls_Sql_TEXT = 'R.I (IFMS_NRRQ) IFMS – DACSES notice generation date needs to be in NRRQ record for Federal Tax Offset annual notice generation';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (IFMS_NRRQ) IFMS – DACSES notice generation date needs to be in NRRQ record for Federal Tax Offset annual notice generation',
          'FIN',
          'IFMS_Y1',
          'Case_IDNO - MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + ' - ' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM IFMS_Y1 A
    WHERE A.TypeTransaction_CODE IN ('A', 'M')
      AND A.WorkerUpdate_ID = 'CONVERSION'
      AND NOT EXISTS (SELECT 1
                        FROM NRRQ_Y1 B
                       WHERE B.Notice_ID = 'ENF-24'
                         AND B.Case_IDNO = A.Case_IDNO
                         AND B.Recipient_ID = A.MemberMci_IDNO)
    GROUP BY a.Case_IDNO,
             a.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I (ISTX_NRRQ) ISTX - DACSES notice generation date needs to be in ISTX record for State Tax Offset annual notice generation';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ISTX_NRRQ) ISTX - DACSES notice generation date needs to be in ISTX record for State Tax Offset annual notice generation',
          'FIN',
          'ISTX_Y1',
          'Case_IDNO - MemberMci_IDNO',
          CAST(a.Case_IDNO AS VARCHAR) + ' - ' + CAST(a.MemberMci_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM ISTX_Y1 A
    WHERE A.TypeTransaction_CODE IN ('I', 'C')
      AND A.WorkerUpdate_ID = 'CONVERSION'
      AND NOT EXISTS (SELECT 1
                        FROM ISTX_Y1 B
                       WHERE B.MemberMci_IDNO = A.MemberMci_IDNO
                         AND B.Case_IDNO = A.Case_IDNO
                         AND B.TypeTransaction_CODE = 'L'
                         AND A.WorkerUpdate_ID = B.WorkerUpdate_ID)
    GROUP BY a.Case_IDNO,
             a.MemberMci_IDNO;

   SET @Ls_Sql_TEXT = 'R.I NMSN activity chain was converted at the wrong step';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I NMSN activity chain was converted at the wrong step',
          'Enforcement',
          'DMNR_Y1',
          'ENTERED_DATE',
          ENTERED_DATE,
          COUNT(1),
          '1' AS severity
     FROM DMNR_y1
    WHERE ACTIVITYMINOR_CODE = 'RRMSN'
      AND ENTERED_DATE <= DATEADD(dd, -46, @Ad_Conversion_DATE)
    GROUP BY ENTERED_DATE,
             ACTIVITYMINOR_CODE;

   SET @Ls_Sql_TEXT = 'FIDM activity chain converted at the wrong step';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT,
          'Enforcement',
          'DMNR_Y1',
          'ENTERED_DATE',
          ENTERED_DATE,
          COUNT(1),
          '1' AS severity
     FROM DMNR_y1
    WHERE ACTIVITYMINOR_CODE = 'ANCPA'
      AND ENTERED_DATE < DATEADD(dd, -23, @Ad_Conversion_DATE)
    GROUP BY ENTERED_DATE,
             ACTIVITYMINOR_CODE;

   SET @Ls_Sql_TEXT = 'FEDH TABLE DOES NOT HAVE ADDRESS FOR THE MEMBER';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT DescriptionError_TEXT,
          FunctionalArea_TEXT,
          Table_NAME,
          EntityType_TEXT,
          Entity_ID,
          ErrorCount_QNTY,
          Error_Severity_Code
     FROM (SELECT @Ls_Sql_TEXT DescriptionError_TEXT,
                  'ENFORCEMENT'FunctionalArea_TEXT,
                  'FEDH_Y1'Table_NAME,
                  'LINE1_ADDR'EntityType_TEXT,
                  a.MemberMci_IDNO Entity_ID,
                  COUNT (1) ErrorCount_QNTY,
                  '1'Error_Severity_Code,
                  (SELECT COUNT(1)
                     FROM FEDH_Y1 b
                    WHERE LINE1_ADDR = ' ') Total_ErrorCount_QNTY
             FROM FEDH_Y1 a
            WHERE LINE1_ADDR = ' '
            GROUP BY MemberMci_IDNO) A
    WHERE Total_ErrorCount_QNTY > 1000;

   SET @Ls_Sql_TEXT = 'Mismatch between records types in ISTX and SLST';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT,
          'FIN',
          'ISTX_Y1',
          'MemberMci_IDNO - Case_IDNO',
          CAST(X.MemberMci_IDNO AS VARCHAR) + ' - ' + CAST(X.Case_IDNO AS VARCHAR),
          COUNT (1),
          '1'
     FROM ISTX_Y1 X
    WHERE EXISTS (SELECT 1
                    FROM ISTX_Y1 A,
                         ISTX_Y1 B,
                         SLST_Y1 C
                   WHERE A.MemberMci_IDNO = X.MemberMci_IDNO
                     AND A.Case_IDNO = X.Case_IDNO
                     AND A.WorkerUpdate_ID = 'CONVERSION'
                     AND A.SubmitLast_DATE < @ad_Conversion_DATE
                     AND A.TypeTransaction_CODE <> 'L'
                     AND B.MemberMci_IDNO = A.MemberMci_IDNO
                     AND B.Case_IDNO = A.Case_IDNO
                     AND B.TypeArrear_CODE = A.TypeArrear_CODE
                     AND B.WorkerUpdate_ID = 'CONVERSION'
                     AND B.SubmitLast_DATE < @ad_Conversion_DATE
                     AND B.TypeTransaction_CODE = 'L'
                     AND C.MemberMci_IDNO = B.MemberMci_IDNO
                     AND C.WorkerUpdate_ID = 'CONVERSION'
                     AND C.SubmitLast_DATE < @ad_Conversion_DATE
                     AND C.TypeTransaction_CODE = 'L')
      AND X.WorkerUpdate_ID = 'CONVERSION'
    GROUP BY X.MemberMci_IDNO,
             X.Case_IDNO
    ORDER BY X.MemberMci_IDNO,
             X.Case_IDNO;

   SET @Ls_Sql_TEXT = 'Responding Case with MHIS program type other than N – Non TANF';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT,
          'CASE MANAGEMENT',
          'CASE_Y1',
          'CASE',
          A.Case_IDNO,
          COUNT (1),
          '1'
     FROM CASE_Y1 A
    WHERE respondinit_code = 'R'
      AND EXISTS (SELECT 1
                    FROM mhis_y1
                   WHERE case_idno = a.case_idno
                     AND end_date = '12/31/9999'
                     AND typewelfare_code <> 'N')
    GROUP BY A.Case_IDNO;

   SET @Ls_Sql_TEXT = 'R.I File Id from dprs_Y1,DCKT_Y1 not Exist in FDEM_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Establishment' AS FunctionalArea_TEXT,
          'FDEM_Y1' AS Table_NAME,
          'File_ID' AS EntityType_TEXT,
          CAST(DP.File_ID AS VARCHAR)AS ENTITY_ID,
          COUNT (1) ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM DPRS_Y1 DP,
          DCKT_Y1 DC
    WHERE DP.FILE_ID = DC.FILE_ID
      AND DP.EndValidity_DATE = '12/31/9999'
      AND NOT EXISTS (SELECT 1
                        FROM FDEM_Y1
                       WHERE FILE_ID = DC.FILE_ID
                         AND EndValidity_DATE = '12/31/9999')
    GROUP BY CAST(DP.File_ID AS VARCHAR);

   SET @Ls_Sql_TEXT = 'R.I File Id from DPRS_Y1,DCKT_Y1 not Exist in Case';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Establishment' AS FunctionalArea_TEXT,
          'FDEM_Y1' AS Table_NAME,
          'File_ID' AS EntityType_TEXT,
          CAST(DP.File_ID AS VARCHAR)AS ENTITY_ID,
          COUNT (1) ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM DPRS_Y1 DP,
          DCKT_Y1 DC
    WHERE DP.FILE_ID = DC.FILE_ID
      AND DP.EndValidity_DATE = '12/31/9999'
      AND EXISTS (SELECT 1
                    FROM cmem_y1 c,
                         sord_y1 d
                   WHERE c.membermci_idno = dp.docketperson_idno
                     AND c.CaseRelationship_CODE IN ('A', 'P', 'C')
                     AND c.CaseMemberStatus_CODE = 'A'
                     AND c.case_idno = d.case_idno
					 AND dp.file_id = d.file_id)
      AND (NOT EXISTS (SELECT 1
                         FROM cmem_y1 c,
                              sord_y1 d
                        WHERE c.membermci_idno = dp.docketperson_idno
                          AND c.CaseRelationship_CODE IN ('A', 'P', 'C')
                          AND c.CaseMemberStatus_CODE = 'A'
                          AND c.case_idno = d.case_idno
                          AND dp.file_id = d.file_id)
            OR NOT EXISTS (SELECT 1
                             FROM cmem_y1 c,
                                  case_y1 d
                            WHERE c.membermci_idno = dp.docketperson_idno
                              AND c.CaseRelationship_CODE IN ('A', 'P', 'C')
                              AND c.CaseMemberStatus_CODE = 'A'
                              AND c.case_idno = d.case_idno
                              AND dp.file_id = d.file_id))
    GROUP BY CAST(DP.File_ID AS VARCHAR);

   SET @Ls_Sql_TEXT = 'RCTH_Y1 Posting type mismatch with HIMS_Y1 posting type';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'FINANCIAL' AS FunctionalArea_TEXT,
          'RCTH_Y1' AS Table_NAME,
          'SourceReceipt_CODE-TypePosting_CODE' AS EntityType_TEXT,
          SourceReceipt_CODE + '-' + a.TypePosting_CODE AS Entity_ID,
          COUNT(1) AS ErrorCount_QNTY,
          '1' AS Error_Severity_Code
     FROM RCTH_Y1 a
    WHERE EXISTS (SELECT 1
                    FROM HIMS_Y1 b
                   WHERE a.SourceReceipt_CODE = b.SourceReceipt_CODE
                     AND a.TypePosting_CODE <> b.TypePosting_CODE
                     AND b.EndValidity_DATE = '12/31/9999')
    GROUP BY SourceReceipt_CODE + '-' + TypePosting_CODE;

   SET @Ls_Sql_TEXT = 'Open Case Order is End dated but Case is having arrear balance';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'Open Case Order is End dated but Case is having arrear balance' AS DescriptionError_TEXT,
          'FINANCIAL' AS FunctionalArea_TEXT,
          'LSUP_Y1' AS Table_NAME,
          'Case_IDNO-Arrear_Amnt' AS EntityType_TEXT,
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Arrear_Amnt AS VARCHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '1' AS Error_Severity_Code
     FROM (SELECT Case_IDNO,
                  ISNULL (SUM ((OweTotNaa_AMNT - AppTotNaa_AMNT) + (OweTotPaa_AMNT - AppTotPaa_AMNT) + (OweTotTaa_AMNT - AppTotTaa_AMNT) + (OweTotCaa_AMNT - AppTotCaa_AMNT) + (OweTotUpa_AMNT - AppTotUpa_AMNT) + (OweTotUda_AMNT - AppTotUda_AMNT) + (OweTotIvef_AMNT - AppTotIvef_AMNT) + (OweTotNffc_AMNT - AppTotNffc_AMNT) + (OweTotMedi_AMNT - AppTotMedi_AMNT) + (OweTotNonIvd_AMNT - AppTotNonIvd_AMNT) - (OweTotCurSup_AMNT - AppTotCurSup_AMNT)), 0) Arrear_Amnt
             FROM LSUP_Y1 a
            WHERE a.SupportYearMonth_NUMB = (SELECT MAX (c.SupportYearMonth_NUMB)
                                               FROM LSUP_Y1 c
                                              WHERE c.Case_IDNO = a.Case_IDNO
                                                AND c.OrderSeq_NUMB = a.OrderSeq_NUMB
                                                AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB)
              AND a.EventGlobalSeq_NUMB = (SELECT MAX (EventGlobalSeq_NUMB)
                                             FROM LSUP_Y1 d
                                            WHERE d.Case_IDNO = a.Case_IDNO
                                              AND d.OrderSeq_NUMB = a.OrderSeq_NUMB
                                              AND d.ObligationSeq_NUMB = a.ObligationSeq_NUMB
                                              AND d.SupportYearMonth_NUMB = a.SupportYearMonth_NUMB)
            GROUP BY Case_IDNO)A
    WHERE Arrear_Amnt > 0
      AND EXISTS (SELECT 1
                    FROM CASE_Y1 B
                   WHERE A.Case_IDNO = B.Case_IDNO
                     AND B.StatusCase_CODE = 'O')
      AND NOT EXISTS (SELECT 1
                        FROM SORD_Y1 B
                       WHERE A.Case_IDNO = B.Case_IDNO
                         AND OrderEnd_DATE > = @Ad_Conversion_DATE
                         AND B.EndValidity_DATE = '12/31/9999')
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.Arrear_Amnt AS VARCHAR)

   SET @Ls_Sql_TEXT = 'DopAttached_CODE should be Not Needed when Declaration_INDC is No';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'VAPP_Y1' AS Table_NAME,
          'DopAttached_CODE' AS EntityType_TEXT,
          DopAttached_CODE,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM VAPP_Y1 a
    WHERE Declaration_INDC = 'N'
      AND DopAttached_CODE <> 'N'
      AND TypeDocument_CODE = 'VAP'
    GROUP BY DopAttached_CODE;

   SET @Ls_Sql_TEXT = 'DopAttached_CODE should be Yes when Declaration_INDC is Yes and VapPresumedFather_CODE is populated and DOP record is Completed';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'VAPP_Y1' AS Table_NAME,
          'DopAttached_CODE' AS EntityType_TEXT,
          DopAttached_CODE,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM VAPP_Y1
    WHERE Declaration_INDC = 'Y'
      AND DopAttached_CODE <> 'Y'
      AND TypeDocument_CODE = 'VAP'
      AND VapPresumedFather_CODE <> ''
      AND ChildBirthCertificate_ID IN (SELECT ChildBirthCertificate_ID
                                         FROM VAPP_Y1
                                        WHERE TypeDocument_CODE = 'DOP'
                                          AND DataRecordStatus_CODE = 'C')
    GROUP BY DopAttached_CODE;

   SET @Ls_Sql_TEXT = 'DopAttached_CODE should be Not Needed when NoPresumedFather_CODE is populated';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'VAPP_Y1' AS Table_NAME,
          'DopAttached_CODE' AS EntityType_TEXT,
          DopAttached_CODE,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM VAPP_Y1
    WHERE Declaration_INDC = 'Y'
      AND DopAttached_CODE <> 'N'
      AND TypeDocument_CODE = 'VAP'
      AND NoPresumedFather_CODE <> ''
    GROUP BY DopAttached_CODE;

   SET @Ls_Sql_TEXT = 'VapAttached_CODE should be Yes when a Completed VAP document exists';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'VAPP_Y1' AS Table_NAME,
          'VapAttached_CODE' AS EntityType_TEXT,
          VapAttached_CODE,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM VAPP_Y1
    WHERE VapAttached_CODE <> 'Y'
      AND TypeDocument_CODE = 'DOP'
      AND DopPresumedFather_CODE <> ''
      AND ChildBirthCertificate_ID IN (SELECT ChildBirthCertificate_ID
                                         FROM VAPP_Y1
                                        WHERE TypeDocument_CODE = 'VAP'
                                          AND DataRecordStatus_CODE = 'C')
    GROUP BY VapAttached_CODE;

   SET @Ls_Sql_TEXT = 'VapAttached_CODE should be Pending when a non Completed VAP document exists';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ESTABLISHMENT' AS FunctionalArea_TEXT,
          'VAPP_Y1' AS Table_NAME,
          'VapAttached_CODE' AS EntityType_TEXT,
          VapAttached_CODE,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM VAPP_Y1
    WHERE VapAttached_CODE <> 'P'
      AND TypeDocument_CODE = 'DOP'
      AND DopPresumedFather_CODE <> ''
      AND ChildBirthCertificate_ID IN (SELECT ChildBirthCertificate_ID
                                         FROM VAPP_Y1
                                        WHERE TypeDocument_CODE = 'VAP'
                                          AND DataRecordStatus_CODE <> 'C')
    GROUP BY VapAttached_CODE;

   SET @Ls_Sql_TEXT = 'MHIS record for TANF exists for the CP but not for the child';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'CASE MANAGEMENT' AS FunctionalArea_TEXT,
          'MHIS_Y1' AS Table_NAME,
          'MEMBERMCI_IDNO-Case_IDNO' AS EntityType_TEXT,
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '2' AS Error_Severity_Code
     FROM mhis_y1 a
    WHERE a.TypeWelfare_CODE = 'A'
      AND NOT EXISTS (SELECT 1
                        FROM mhis_y1 b,
                             cmem_y1 c
                       WHERE a.case_idno = b.case_idno
                         AND b.membermci_idno = c.membermci_idno
                         AND c.caserelationship_code = 'D'
                         AND b.typewelfare_code = 'A')
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'MHIS record for Medicaid exists for the CP but not for the child';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'CASE MANAGEMENT' AS FunctionalArea_TEXT,
          'MHIS_Y1' AS Table_NAME,
          'MEMBERMCI_IDNO-Case_IDNO' AS EntityType_TEXT,
          CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '2' AS Error_Severity_Code
     FROM mhis_y1 a
    WHERE a.TypeWelfare_CODE = 'M'
      AND NOT EXISTS (SELECT 1
                        FROM mhis_y1 b,
                             cmem_y1 c
                       WHERE a.case_idno = b.case_idno
                         AND b.membermci_idno = c.membermci_idno
                         AND c.caserelationship_code = 'D'
                         AND b.typewelfare_code IN ('A', 'M'))
      AND NOT EXISTS (SELECT 1
                        FROM case_y1
                       WHERE statuscase_code = 'C'
                         AND case_idno = a.casE_idno)
      AND EXISTS (SELECT 1
                    FROM case_y1
                   WHERE casecategory_code = 'MO'
                     AND case_idno = a.casE_idno)
    GROUP BY CAST(a.Case_IDNO AS VARCHAR) + '-' + CAST(a.MemberMci_IDNO AS VARCHAR);

   SET @Ls_Sql_TEXT = 'Active EFT is not exists for US FIPS code in EFTR table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'FINANCIAL' AS FunctionalArea_TEXT,
          'EFTR_Y1' AS Table_NAME,
          'CheckRecipient_ID-OBLE_Record_Count-StateFips_CODE-State_ADDR-Country_ADDR' AS EntityType_TEXT,
          RTRIM(CheckRecipient_ID) + '-' + CAST(OBLE_Record_Count AS VARCHAR) + '-' + StateFips_CODE + '-' + State_ADDR + '-' + Country_ADDR AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '4' AS Error_Severity_Code
     FROM (SELECT CheckRecipient_ID,
                  COUNT(1)OBLE_Record_Count,
                  SUBSTRING(Checkrecipient_ID, 1, 2) StateFips_CODE,
                  ISNULL((SELECT DISTINCT
                                 State_ADDR
                            FROM FIPS_Y1 b
                           WHERE b.StateFips_CODE = SUBSTRING(Checkrecipient_ID, 1, 2)
                             AND b.endvalidity_date = '12/31/9999'), '')State_ADDR,
                  ISNULL((SELECT DISTINCT
                                 Country_ADDR
                            FROM FIPS_Y1 b
                           WHERE b.Fips_CODE = Checkrecipient_ID
                             AND b.endvalidity_date = '12/31/9999'), '')Country_ADDR
             FROM oble_y1 a
            WHERE checkrecipient_CODE = '2'
              AND endvalidity_date = '12/31/9999'
              -- Excluding South Carolina State
              AND SUBSTRING(Checkrecipient_ID, 1, 2) <> '45'
              AND NOT EXISTS (SELECT 1
                                FROM eftr_y1 b
                               WHERE a.checkrecipient_ID = b.checkrecipient_ID
                                 AND StatusEft_CODE = 'AC'
                                 AND b.endvalidity_date = '12/31/9999')
              AND EXISTS (SELECT 1
                            FROM FIPS_y1 b
                           WHERE a.checkrecipient_ID = b.Fips_CODE
                             AND b.endvalidity_date = '12/31/9999')
            GROUP BY checkrecipient_ID) A
    WHERE Country_ADDR = 'US'
    GROUP BY RTRIM(CheckRecipient_ID) + '-' + CAST(OBLE_Record_Count AS VARCHAR) + '-' + StateFips_CODE + '-' + State_ADDR + '-' + Country_ADDR

   SET @Ls_Sql_TEXT = 'ReasonStatus_CODE is empty for unidentified status receipts';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Financial' AS FunctionalArea_TEXT,
          'RCTH_Y1' AS Table_NAME,
          'ReasonStatus_CODE' AS EntityType_TEXT,
          a.ReasonStatus_CODE AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '1' AS Error_Severity_Code
     FROM RCTH_Y1 a
    WHERE a.StatusReceipt_CODE = 'U'
      AND a.ReasonStatus_CODE = ''
      AND a.EndValidity_DATE = '12/31/9999'
    GROUP BY a.ReasonStatus_CODE;

   SET @Ls_Sql_TEXT = 'Topic_IDNO should be unique in DMNR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'DMNR_Y1' AS Table_NAME,
          'Topic_IDNO' AS EntityType_TEXT,
          CAST(Topic_IDNO AS CHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '1' AS Error_Severity_Code
     FROM UDMNR_V1
    GROUP BY Topic_IDNO
   HAVING COUNT(1) > 1;

   SET @Ls_Sql_TEXT = 'R.I (ICAS_FIPS) ICAS_Y1.IVDOutOfStateOfficeFips_CODE NOT IN FIPS_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT 'R.I (ICAS_FIPS) ICAS_Y1.IVDOutOfStateOfficeFips_CODE NOT IN FIPS_Y1' AS DescriptionError_TEXT,
          'CASE MANAGEMENT' AS FunctionalArea_TEXT,
          'ICAS_Y1' AS Table_NAME,
          'IVDOutOfStateOfficeFips_CODE' AS EntityType_TEXT,
          CAST(a.IVDOutOfStateOfficeFips_CODE AS VARCHAR) AS Entity_ID,
          COUNT(1) AS ErrorCount_QNTY,
          '1' AS Error_Severity_Code
     FROM ICAS_Y1 a
    WHERE NOT EXISTS (SELECT 1
                        FROM FIPS_Y1 b
                       WHERE a.IVDOutOfStateOfficeFips_CODE = b.OfficeFips_CODE)
      AND EndValidity_DATE = '12/31/9999'
    GROUP BY IVDOutOfStateOfficeFips_CODE;

   --Defect 3500
   SET @Ls_Sql_TEXT = 'Schedule information should have corresponding entry in DMNR_Y1 table';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Enforcenment' AS FunctionalArea_TEXT,
          'SWKS_Y1' AS Table_NAME,
          'Case_IDNO - Schedule_NUMB' AS EntityType_TEXT,
          CAST(Case_IDNO AS CHAR) + ' - ' + CAST(Schedule_NUMB AS CHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '2' AS Error_Severity_Code
     FROM SWKS_Y1 A
    WHERE NOT EXISTS (SELECT 1
                        FROM DMNR_Y1 o
                       WHERE o.Schedule_NUMB = a.Schedule_NUMB
                         AND o.Case_IDNO = a.Case_IDNO
                         AND o.ActivityMajor_CODE = a.ActivityMajor_CODE
                         AND o.ActivityMinor_CODE = a.ActivityMinor_CODE)
    GROUP BY Case_IDNO,
             Schedule_NUMB;

   --Defect 12601
   SET @Ls_Sql_TEXT = 'NOTE record should have corresponding DMJR_Y1 record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Customer Support' AS FunctionalArea_TEXT,
          'DMJR_Y1' AS Table_NAME,
          'Case_IDNO - Category_CODE - MajorIntSeq_NUMB' AS EntityType_TEXT,
          RTRIM(CAST(Case_IDNO AS CHAR)) + ' - ' + Category_CODE + ' - ' + CAST(MajorIntSeq_NUMB AS CHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM NOTE_Y1 n
    WHERE WorkerUpdate_ID = 'CONVERSION'
      AND NOT EXISTS (SELECT 1
                        FROM DMJR_Y1 u
                       WHERE u.Case_IDNO = n.Case_IDNO
                         AND u.Subsystem_CODE = n.Category_CODE
                         AND u.activitymajor_code = 'CASE'
                         AND u.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
                         AND u.WorkerUpdate_ID = 'CONVERSION')
    GROUP BY Case_IDNO,
             Category_CODE,
             MajorIntSeq_NUMB
    ORDER BY Case_IDNO,
             MajorIntSeq_NUMB;

   --12602
   SET @Ls_Sql_TEXT = 'NOTE record should have corresponding UDMNR_V1 record';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Cusrtomer Service' AS FunctionalArea_TEXT,
          'UDMNR_V1' AS Table_NAME,
          'Case_IDNO - Subject_CODE - Topic_IDNO - MajorIntSeq_NUMB - MinorIntSeq_NUMB' AS EntityType_TEXT,
          CAST(Case_IDNO AS CHAR) + ' - ' + Subject_CODE + ' - ' + CAST(Topic_IDNO AS CHAR) + ' - ' + CAST(MajorIntSeq_NUMB AS CHAR) + ' - ' + CAST(MinorIntSeq_NUMB AS CHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '3' AS Error_Severity_Code
     FROM NOTE_Y1 n
    WHERE WorkerUpdate_ID = 'CONVERSION'
      AND NOT EXISTS (SELECT 1
                        FROM UDMNR_V1 u
                       WHERE u.Case_IDNO = n.Case_IDNO
                         AND u.ActivityMinor_CODE = n.Subject_CODE
                         AND u.Subsystem_CODE = n.Category_CODE
                         AND u.Topic_IDNO = n.Topic_IDNO
                         AND u.MajorIntSeq_NUMB = n.MajorIntSeq_NUMB
                         AND u.MinorIntSeq_NUMB = n.MinorIntSeq_NUMB
                         AND u.WorkerUpdate_ID = 'CONVERSION')
    GROUP BY Case_IDNO,
             Subject_CODE,
             Topic_IDNO,
             MajorIntSeq_NUMB,
             MinorIntSeq_NUMB
    ORDER BY Case_IDNO,
             Subject_CODE;

   --5179
   SET @Ls_Sql_TEXT = 'Open Non IV-D Collections only Cases with a valid employer and current charging obligation but do not have open IMIW remedies in DMJR. Non IV-D collections only cases can only be collected via Wage withholding';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'ENFORCEMENT' AS FunctionalArea_TEXT,
          'DMJR_Y1' AS Table_NAME,
          'a.case_idno-a.typecase_code-a.casecategory_code-a.statuscase_code-a.worker_id-c.membermci_idno-d.othpPartyempl_idno-d.endemployment_date-d.status_code' AS EntityType_TEXT,
          CAST(a.case_idno AS VARCHAR) + '-' + a.typecase_code + '-' + a.casecategory_code + '-' + a.statuscase_code + '-' + CAST(RTRIM(a.worker_id) AS VARCHAR) + '-' + CAST(c.membermci_idno AS VARCHAR) + '-' + CAST(d.othpPartyempl_idno AS VARCHAR) + '-' + CAST(d.endemployment_date AS VARCHAR) + '-' + d.status_code AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '2' AS Error_Severity_Code
     FROM case_Y1 a,
          cmem_Y1 c,
          ehis_Y1 d
    WHERE a.case_idno = c.case_idno
      AND c.membermci_idno = d.membermci_idno
      AND a.typecase_code = 'H'
      AND statuscase_code = 'O'
      AND a.casecategory_code = 'CO'
      AND c.caserelationship_code IN ('A', 'P')
      AND d.employerprime_indc = 'Y'
      AND d.endemployment_date > GETDATE()
      AND EXISTS (SELECT *
                    FROM sord_Y1
                   WHERE case_idno = a.case_idno
                     AND iiwo_code = 'I'
                     AND orderend_date > '10/01/2013')
      AND EXISTS (SELECT *
                    FROM oble_Y1
                   WHERE case_idno = a.case_idno
                     AND typedebt_code = 'CS'
                     AND periodic_amnt > 0
                     AND endobligation_date > '10/01/2013')
      AND NOT EXISTS (SELECT *
                        FROM dmjr_Y1
                       WHERE case_idno = a.case_idno
                         AND activitymajor_code = 'IMIW')
    GROUP BY CAST(a.case_idno AS VARCHAR) + '-' + a.typecase_code + '-' + a.casecategory_code + '-' + a.statuscase_code + '-' + CAST(RTRIM(a.worker_id) AS VARCHAR) + '-' + CAST(c.membermci_idno AS VARCHAR) + '-' + CAST(d.othpPartyempl_idno AS VARCHAR) + '-' + CAST(d.endemployment_date AS VARCHAR) + '-' + d.status_code;

   --9333
   SET @Ls_Sql_TEXT = 'Forum_IDNO should be unique in DMJR_Y1';

   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          @Ls_Sql_TEXT,
          'S';

   INSERT CRIR_Y1
          (DescriptionError_TEXT,
           FunctionalArea_TEXT,
           Table_NAME,
           EntityType_TEXT,
           Entity_ID,
           ErrorCount_QNTY,
           Error_Severity_Code)
   SELECT @Ls_Sql_TEXT AS DescriptionError_TEXT,
          'Enforcement' AS FunctionalArea_TEXT,
          'DMJR_Y1' AS Table_NAME,
          'Forum_IDNO' AS EntityType_TEXT,
          CAST(Forum_IDNO AS CHAR) AS Entity_ID,
          COUNT (1) AS ErrorCount_QNTY,
          '2' AS Error_Severity_Code
     FROM DMJR_Y1
    GROUP BY Forum_IDNO
   HAVING COUNT(1) > 1;

   -- Querys Ends
   INSERT CRIRLog_Y1
          (Conversion_DATE,
           ExecutedQuery_TEXT,
           Status_Code)
   SELECT @Ad_Conversion_DATE,
          'COMMON$SP_VALIDATE_CONVERSIONDATA_RI Execution IS Completed. Please CHECK Result IN CRIR_Y1 TABLE',
          'S';
  END Try

  BEGIN Catch
   SELECT 'Error IN ' + ERROR_PROCEDURE () + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT
  END Catch
 END
GO
