/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$INSERT_NOTICE_DATA]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$INSERT_NOTICE_DATA
Programmer Name	:	IMP Team.
Description		:	This procedure is used to insert the data in NMRQ_Y1, NRRQ_Y1,NXML/AXML tables
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_GENERATE_NOTICE
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$INSERT_NOTICE_DATA]
 @Ac_PrintMethod_CODE         CHAR(2),
 @An_BarcodeIn_NUMB           NUMERIC(12) = 0,
 @An_Barcode_NUMB             NUMERIC(12),
 @Ad_Generate_DATE            DATE,
 @An_TransactionEventSeq_NUMB NUMERIC(19),
 @As_Xml_TEXT                 VARCHAR(MAX),
 @Ac_TypeService_CODE         CHAR(1) = '',
 @Ac_TypeAddress_CODE         CHAR(1) = '',
 @Ac_Msg_CODE                 VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT    VARCHAR(4000) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Li_Zero_NUMB                INT				= 0,
          @Li_Rowcount_QNTY            SMALLINT,
          @Ln_NoticeXml_Case_IDNO      NUMERIC(6),
          @Lc_StatusSuccess_CODE       CHAR(1)			= 'S',
          @Lc_StatusFailed_CODE        CHAR(1)			= 'F',
          @Lc_NoticeXml_Recipient_CODE CHAR(2),
          @Lc_NoticeXml_Notice_ID      CHAR(8),
          @Lc_NoticeXml_Recipient_ID   CHAR(10),
          @Lc_WorkerPrinted_ID         CHAR(30),
          @Ls_Routine_TEXT             VARCHAR(60)		= 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA',
          @Ls_Sql_TEXT                 VARCHAR(100)		= '',
          @Ls_Sqldata_TEXT             VARCHAR(1000)	= ' ',
          @Ls_Err_Description_TEXT     VARCHAR(MAX),
          @Ls_Col_Name_TEXT            VARCHAR(MAX),
          @Ls_InsertTblName_TEXT       VARCHAR(MAX),
          @Ls_Data_type_TEXT           VARCHAR(MAX),
          @Ls_valuesList_TEXT          VARCHAR(MAX)		= '',
          @Ls_values_TEXT              VARCHAR(100),
          @Ls_Execsql_TEXT             VARCHAR(MAX),
          @Ls_InputValues_TEXT         VARCHAR(MAX),
          @Ls_MaskedNoticeXml_TEXT     VARCHAR(MAX),
          @Ld_Update_DTTM              DATETIME2,
          @Ld_Generate_DTTM            DATETIME2,
          @InsertRecp_Details_CUR      CURSOR;

 
  BEGIN TRY
   SET @As_Xml_TEXT = REPLACE(@As_Xml_TEXT, '&amp;amp;', '&amp;');

   IF @Ac_TypeAddress_CODE != ''
    BEGIN
     IF @Ac_PrintMethod_CODE = 'L'
         OR (@Ac_PrintMethod_CODE = 'E'
             AND @Ac_TypeService_CODE IN ('G', 'O'))
      BEGIN
       SET @Ls_InsertTblName_TEXT = 'NoticeReprintRequest_T1';
      END
     ELSE
      BEGIN
       SET @Ls_InsertTblName_TEXT = 'NoticePrintRequest_T1';
      END

     -- To update Recipient_Code value from 4 characters to 2 characters. This will be useful only for FIN-19 notice
     UPDATE #NoticeElementsData_P1
        SET Element_VALUE = SUBSTRING(Element_VALUE, 1, 2)
      WHERE Element_NAME = 'Recipient_CODE';

     DECLARE @NoticeElementsData_p1 TABLE(
      Element_NAME  VARCHAR(150),
      Element_VALUE VARCHAR(MAX));

     INSERT INTO @NoticeElementsData_p1
     SELECT *
       FROM #NoticeElementsData_P1

	 UPDATE @NoticeElementsData_p1
        SET Element_VALUE = REPLACE(Element_VALUE, '&amp;', '&'),
			Element_NAME = CASE WHEN Element_NAME LIKE 'Recipient%'
									 AND Element_NAME NOT IN ('Recipient_Id', 'Recipient_NAME', 'Recipient_CODE')
								THEN REPLACE(Element_NAME,'Recipient_','Recipient')
								ELSE Element_NAME
						   END;
						   
	 -- Defect 13473 - Notice Generation Timeout Fix - Start --
     SET @InsertRecp_Details_CUR = CURSOR
     FOR SELECT '''' + CASE WHEN i.Column_NAME = 'notice_id' 
							THEN ISNULL(REPLACE(UPPER(LTRIM(RTRIM(t.Element_VALUE))), '''', ''''''), '')
							WHEN i.Data_Type = 'date'
							THEN CONVERT(VARCHAR, t.Element_VALUE, 101)
							WHEN i.Data_Type = 'datetime2'
							THEN CONVERT(VARCHAR, t.Element_VALUE, 120)
							WHEN i.Data_Type = 'numeric'
							THEN ISNULL(t.Element_VALUE, 0)
							ELSE ISNULL(REPLACE(LTRIM(RTRIM(t.Element_VALUE)), '''', ''''''), ' ')
					   END+''''
           FROM information_schema.columns i
           LEFT JOIN (SELECT n.Element_NAME,
							 n.Element_VALUE,
							ROW_NUMBER() OVER(PARTITION BY n.Element_NAME ORDER BY n.Element_VALUE) Row_NUMB
					   FROM @NoticeElementsData_p1 n) as t
             ON t.Element_NAME = i.Column_NAME
            AND t.Row_NUMB = 1
          WHERE i.Table_NAME = @Ls_InsertTblName_TEXT
          ORDER BY i.Ordinal_Position;
	  -- Defect 13473 - Notice Generation Timeout Fix - End --
	
     OPEN @InsertRecp_Details_CUR

     FETCH NEXT FROM @InsertRecp_Details_CUR INTO @Ls_values_TEXT

     WHILE @@FETCH_STATUS = 0
      BEGIN
       SET @Ls_valuesList_TEXT = @Ls_valuesList_TEXT + @Ls_values_TEXT+', ';

       FETCH NEXT FROM @InsertRecp_Details_CUR INTO @Ls_values_TEXT
      END

     CLOSE @InsertRecp_Details_CUR

     DEALLOCATE @InsertRecp_Details_CUR;

     SET @Ls_InputValues_TEXT = SUBSTRING(LTRIM(RTRIM(@Ls_valuesList_TEXT)), 1, (LEN(LTRIM(RTRIM(@Ls_valuesList_TEXT))) - 1));
     SET @Ls_Sql_TEXT = 'INSERT INTO' + @Ls_InsertTblName_TEXT;
     SET @Ls_Sqldata_TEXT = 'VALUES: ' + ISNULL(@Ls_InputValues_TEXT, '');
     SET @Ls_Execsql_TEXT = 'INSERT INTO ' + @Ls_InsertTblName_TEXT + '  VALUES(' + @Ls_InputValues_TEXT + ');'
     EXEC (@Ls_Execsql_TEXT);
     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = @Li_Zero_NUMB
      RAISERROR(50001,16,1);
    END
   ELSE
    BEGIN
     INSERT INTO @NoticeElementsData_p1
     SELECT *
       FROM #NoticeElementsData_P1;

     SELECT @Lc_WorkerPrinted_ID = Element_VALUE
       FROM @NoticeElementsData_P1
      WHERE Element_NAME = 'WorkerPrinted_ID';

     SELECT @Ld_Generate_DTTM = Element_VALUE
       FROM @NoticeElementsData_P1
      WHERE Element_NAME = 'Generate_DTTM';

     SELECT @Ld_Update_DTTM = Element_VALUE
       FROM @NoticeElementsData_P1
      WHERE Element_NAME = 'Update_DTTM';

     INSERT INTO NRRQ_Y1
     SELECT Notice_ID,
            Case_IDNO,
            Recipient_ID,
            @An_Barcode_NUMB,
            Recipient_CODE,
            NoticeVersion_NUMB,
            'R',
            @Lc_WorkerPrinted_ID,
            @Lc_WorkerPrinted_ID,
            @Ld_Generate_DTTM,
            'NRRQ',
            Copies_QNTY,
            @An_TransactionEventSeq_NUMB,
            @Ld_Update_DTTM,
            File_ID,
            LoginWrkOficAttn_ADDR,
            LoginWorkersOffice_NAME,
            LoginWrkOficLine1_ADDR,
            LoginWrkOficLine2_ADDR,
            LoginWrkOficCity_ADDR,
            LoginWrkOficState_ADDR,
            LoginWrkOficZip_ADDR,
            LoginWorkerOfficeCountry_ADDR,
            RecipientAttn_ADDR,
            Recipient_NAME,
            RecipientLine1_ADDR,
            RecipientLine2_ADDR,
            RecipientCity_ADDR,
            RecipientState_ADDR,
            RecipientZip_ADDR,
            RecipientCountry_ADDR,
            'L',
            'R',
            @Ld_Generate_DTTM
       FROM NRRQ_Y1
      WHERE Barcode_NUMB = @An_BarcodeIn_NUMB;
    END

   SET @Ls_Sql_TEXT = 'INSERT INTO AXML_Y1/NXML_Y1';
   SET @Ls_Sqldata_TEXT = ' Xml_Result: ' + ISNULL(@As_Xml_TEXT, '');

   IF @As_Xml_TEXT != ''
    BEGIN
     SELECT @Ln_NoticeXml_Case_IDNO = Element_VALUE
       FROM #NoticeElementsData_p1
      WHERE Element_NAME = 'Case_IDNO';

     SELECT @Lc_NoticeXml_Notice_ID = Element_VALUE
       FROM #NoticeElementsData_p1
      WHERE Element_NAME = 'Notice_ID';

     SELECT @Lc_NoticeXml_Recipient_CODE = Element_VALUE
       FROM #NoticeElementsData_p1
      WHERE Element_NAME = 'Recipient_CODE';

     SELECT @Lc_NoticeXml_Recipient_ID = Element_VALUE
       FROM #NoticeElementsData_p1
      WHERE Element_NAME = 'Recipient_ID';

      --13613 - Masking of FV data prior to notice gen Fix - Start
	  --13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -Start
	 SET @Ls_Sql_TEXT = 'BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV';
	 SET @Ls_Sqldata_TEXT = ' Case_IDNO: ' + CAST(ISNULL(@Ln_NoticeXml_Case_IDNO, 0) AS VARCHAR)
						  + ' Notice_ID: ' + CAST(ISNULL(@Lc_NoticeXml_Notice_ID, '') AS VARCHAR)
						  + ' Recipient_CODE: ' + CAST(ISNULL(@Lc_NoticeXml_Recipient_CODE, '') AS VARCHAR)
					      + ' Recipient_ID: ' + CAST(ISNULL(@Lc_NoticeXml_Recipient_ID, '') AS VARCHAR)
						  + ' XmlInput_TEXT: ' + CAST(ISNULL(@As_Xml_TEXT, '') AS VARCHAR(MAX))
     EXECUTE BATCH_GEN_NOTICES$SP_GET_MASKED_XML_FOR_FV
      @An_Case_IDNO             = @Ln_NoticeXml_Case_IDNO,
      @Ac_Notice_ID             = @Lc_NoticeXml_Notice_ID,
      @Ac_Recipient_CODE        = @Lc_NoticeXml_Recipient_CODE,
      @Ac_Recipient_ID          = @Lc_NoticeXml_Recipient_ID,
      @As_XmlInput_TEXT         = @As_Xml_TEXT,
      @As_XmlOut_TEXT           = @Ls_MaskedNoticeXml_TEXT OUTPUT,
      @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
      @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT OUTPUT;

     IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
      BEGIN
       RAISERROR (50001,16,1);
      END
	
     SET @As_Xml_TEXT = @Ls_MaskedNoticeXml_TEXT;
	 --13837 - CR0468 Mask FV Addresses on Petitions from Generation through Submission (DAG Step Masking in Preview)- Fix -End
	 --13613 - Masking of FV data prior to notice gen Fix - End

     IF @Ac_PrintMethod_CODE = 'L'
         OR (@Ac_PrintMethod_CODE = 'E'
             AND @Ac_TypeService_CODE IN ('G', 'O'))
      INSERT INTO AXML_Y1
           VALUES(@An_Barcode_NUMB,
                  @As_Xml_TEXT);
     ELSE
      INSERT INTO NXML_Y1
           VALUES(@An_Barcode_NUMB,
                  @As_Xml_TEXT);

     SET @Li_Rowcount_QNTY = @@ROWCOUNT;

     IF @Li_Rowcount_QNTY = @Li_Zero_NUMB
      RAISERROR(50001,16,1);
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   IF CURSOR_STATUS ('local', '@InsertRecp_Details_CUR') IN (0, 1)
    BEGIN
     CLOSE @InsertRecp_Details_CUR

     DEALLOCATE @InsertRecp_Details_CUR
    END
   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA') + ' PROCEDURE' + '. Error DESC - ' + ISNULL(@As_DescriptionError_TEXT, '') + '. Error EXECUTE Location - ' + ISNULL(@Ls_Sql_TEXT, '') + '. Error List KEY - ' + ISNULL(@Ls_Sqldata_TEXT, '');
    END
   ELSE
    BEGIN
     SET @Ls_Err_Description_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICES$INSERT_NOTICE_DATA') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR);
    END

   SET @As_DescriptionError_TEXT = @Ls_Err_Description_TEXT;
  END CATCH
 END


GO
