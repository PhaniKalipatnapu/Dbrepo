/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_BUILD_XML]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_BUILD_XML
Programmer Name	:	IMP Team.
Description		:	The procedure BATCH_GEN_NOTICES$SP_BUILD_XML is common procedure to generate XML for notice elements that are in NDEL_Y1
Frequency		:	
Developed On	:	5/3/2012
Called By		:	BATCH_GEN_NOTICES$SP_BUILD_XML
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_BUILD_XML]
 @As_Subelements_TEXT      VARCHAR(MAX),
 @As_Result_TEXT           VARCHAR(MAX) OUTPUT,
 @Ac_Msg_CODE              VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(MAX) OUTPUT
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Ls_ErrorDesc_TEXT                        VARCHAR(4000),
          @Lc_printMethod_CODE                      CHAR(1),
          @Ls_Sql_TEXT                              VARCHAR(1000) = '',
          @Ls_Sqldata_TEXT                          VARCHAR(400) = '',
          @Ls_DescriptionError_TEXT                 VARCHAR(4000),
          @Ln_RecipientCount_NUMB                   NUMERIC(3),
          @Ln_NonRecipientCount_NUMB                NUMERIC(3),
          @Ls_Output_TEXT                           VARCHAR(MAX),
          @Ls_EmptyTagList_TEXT                     VARCHAR(MAX),
          @Ls_Result_TEXT                           VARCHAR(MAX),
          @Ls_OutputOption_TEXT                     VARCHAR(MAX) = '',
          @Lc_Notice_ID                             CHAR(8),
          @Lc_Case_IDNO                             CHAR(6),
          @Ln_ErrorCount_NUMB                       NUMERIC(2),
          @Lc_StatusSuccess_CODE                    CHAR,
          @Lc_StatusFailed_CODE                     CHAR,
          @RequiredElements_CUR                     CURSOR,
          @Ls_RequiredInputParam_TEXT               VARCHAR(100),
          @Ls_RequiredInputParamValue_TEXT          VARCHAR(2000),
          @Ls_RequiredParamList_TEXT                VARCHAR(MAX) = '',
          @GetRequired_Element_CUR                  CURSOR,
          @ElementGroup_NUMB                        NUMERIC(2) = 0,
          @Ln_SelectedElementsCount_NUMB            NUMERIC(2) = 0,
          @Ls_Esign_Title_Text                      VARCHAR(100),
          @Ls_e0058desc_text                        VARCHAR(100),
          @Ls_e0076desc_text                        VARCHAR(100),
          @Ln_ElementGroupMinRequired_NUMB          NUMERIC(2) = 0,
          @Ln_ElementGroupMaxRequired_NUMB          NUMERIC(2) = 0,
          @Ln_OptionParentSeq_NUMB                  NUMERIC(5) = 0,
          @Ln_OptionSelectedElementsCount_NUMB      NUMERIC(5) = 0,
          @Ln_ParentElementGroupMinRequired_NUMB    NUMERIC(5) = 0,
          @Ln_ParentElementGroupMaxRequired_NUMB    NUMERIC(5) = 0,
          @Ln_ParentGroupSelectedElementsCount_NUMB NUMERIC(5) = 0,
          @Ln_ParentSelectedElementCount_NUMB       NUMERIC(5) = 0,
          @Ln_ElementGroup_NUMB                     NUMERIC(5) = 0,
          @Ln_Case_IDNO								NUMERIC(6),
          @Ls_SelectedElement_VALUE                 VARCHAR(150) = '',
          @Ln_SelectedElementCount_NUMB             NUMERIC(5) = 0,
          @Ln_GroupElementCount_NUMB                NUMERIC(5) = 0,
          @Lc_ActivityMinor_CODE                    CHAR(5),
          @Lc_ActivityMajor_CODE                    CHAR(5),
          @Lc_ReasonStatus_CODE                     CHAR(2),
          @Lc_No_INDC                               CHAR(1) = 'N',
          @Lc_Worker_ID							    CHAR(30),
          @XmlRequiredElements_CUR                  CURSOR,
          @Ls_Element_NAME                          VARCHAR(100),
          @Ln_PositionStart_NUMB                    NUMERIC(10),
          @Ln_PositionEnd_NUMB                      NUMERIC(10),
          @Ls_Xml_TEXT                              VARCHAR(MAX),
          @Ln_RowCount_NUMB                         NUMERIC(2),
          @Ln_Counter_NUMB                          NUMERIC(2),
          @Ls_ParentElement_NAME                    VARCHAR(100),
          @Ln_RowPositionStart_NUMB                 NUMERIC(10),
          @Ln_ElementCount_NUMB                     NUMERIC(5),
          @Ln_OptionsInSetCount_NUMB                NUMERIC(5),
          @Ld_Run_DATE								DATETIME2;

  SET @Lc_StatusSuccess_CODE = 'S';
  SET @Lc_StatusFailed_CODE = 'F';

  DECLARE @SelectedElements TABLE (
   Element_NAME VARCHAR(150));

  BEGIN TRY
   DECLARE @NoticeErrors_P1 TABLE (
    Element_NAME VARCHAR(150),
    Error_CODE   VARCHAR(18),
    Error_DESC   VARCHAR(300));

   INSERT INTO @NoticeErrors_P1
   SELECT *
     FROM #NoticeErrors_P1

   DECLARE @NoticeElementsData_P1 TABLE (
    Element_NAME  VARCHAR(150),
    Element_VALUE VARCHAR(MAX))

   INSERT INTO @NoticeElementsData_P1
   SELECT *
     FROM #NoticeElementsData_P1

   SET @Ls_Sql_TEXT = 'SELECT @NoticeElementsData_P1'
   SET @Ls_Sqldata_TEXT = ' Notice_ID : ' + ISNULL('Notice_ID', '');
   SET @Lc_Notice_ID =(SELECT Element_VALUE
                         FROM @NoticeElementsData_P1
                        WHERE Element_NAME = 'Notice_ID');
   SET @Lc_printMethod_CODE = (SELECT Element_VALUE
                                 FROM @NoticeElementsData_P1
                                WHERE Element_NAME = 'PrintMethod_CODE');


	--13424 - NNRQ - Run-time Error Fix - Start                  
	--13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - Start              
   SET @Lc_Worker_ID = (SELECT DISTINCT
										CONVERT(VARCHAR(MAX), Element_VALUE) AS Element_VALUE
								   FROM @NoticeElementsData_P1
								  WHERE Element_NAME = 'Worker_Parameter_ID');                                
   --13764 - CR0455 Remapping of Worker Name on Documents 20141205 - Fix - End								  

   SET @Ld_Run_DATE = (SELECT Element_VALUE
								   FROM @NoticeElementsData_P1
								  WHERE Element_NAME = 'Generate_DATE');		
   
   SET @Ln_Case_IDNO = (SELECT Element_VALUE
								   FROM @NoticeElementsData_P1
								  WHERE Element_NAME = 'Case_IDNO');										  
								  
	--13424 - NNRQ - Run-time Error Fix - End								  						  

   IF @Lc_Notice_ID = ''
    BEGIN
     SET @As_DescriptionError_TEXT = 'No Notice_ID IN Local TABLE' + ' ' + ISNULL(@Ls_Sqldata_TEXT, '');

     RAISERROR(50001,16,1)
    END

   SELECT @Ls_e0076desc_text = DescriptionError_TEXT
     FROM EMSG_Y1
    WHERE Error_CODE = 'E0076'

   SELECT @Ls_e0058desc_text = DescriptionError_TEXT
     FROM EMSG_Y1
    WHERE Error_CODE = 'E0058'

   SET @Ls_Sqldata_TEXT = 'ActivityMajor_CODE';
   SET @Lc_ActivityMajor_CODE = (SELECT Element_VALUE
                                   FROM @NoticeElementsData_P1
                                  WHERE Element_NAME = 'ActivityMajor_CODE');
   SET @Ls_Sqldata_TEXT = 'ActivityMinor_CODE';
   SET @Lc_ActivityMinor_CODE = (SELECT Element_VALUE
                                   FROM @NoticeElementsData_P1
                                  WHERE Element_NAME = 'ActivityMinor_CODE');
   SET @Ls_Sqldata_TEXT = 'ReasonStatus_CODE';

   SELECT @Lc_ReasonStatus_CODE = Element_VALUE
     FROM @NoticeElementsData_P1
    WHERE Element_NAME = 'ReasonStatus_CODE';

   /*Start of Error handling for option elements notices (Inserting into @NoticeErrors_P1)*/
   IF @Lc_printMethod_CODE <> 'V'
    BEGIN
     -- Start of Handling errors for option groups  
     IF EXISTS (SELECT 1
                  FROM NDEL_Y1
                 WHERE ElementGroup_NUMB <> 0
                   AND OptionParentSeq_NUMB = 0
                   AND Notice_ID = @Lc_Notice_ID
                   AND Input_CODE = 'O'
                   AND Element_NAME LIKE 'option_%')
      BEGIN
       SET @GetRequired_Element_CUR = CURSOR
       FOR SELECT ElementGroup_NUMB
             FROM NDEL_Y1
            WHERE ElementGroup_NUMB <> 0
              AND OptionParentSeq_NUMB = 0
              AND Notice_ID = @Lc_Notice_ID
              AND Element_NAME LIKE 'option_%'
            GROUP BY ElementGroup_NUMB;

       OPEN @GetRequired_Element_CUR

       FETCH NEXT FROM @GetRequired_Element_CUR INTO @ElementGroup_NUMB

       WHILE @@FETCH_STATUS = 0
        BEGIN
         SELECT TOP 1 @Ln_ElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
                      @Ln_ElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
           FROM NDEL_Y1
          WHERE Notice_ID = @Lc_Notice_ID
            AND Input_CODE = 'O'
            AND ElementGroup_NUMB = @ElementGroup_NUMB;

         -- Fetching the Elements number which has the data in @NoticeElementsData_P1 table in a elements group
         SELECT @Ln_SelectedElementsCount_NUMB = COUNT(Element_NAME)
           FROM @NoticeElementsData_P1
          WHERE Element_NAME IN (SELECT Element_NAME
                                   FROM NDEL_Y1
                                  WHERE Notice_ID = @Lc_Notice_ID
                                    AND Input_CODE = 'O'
                                    AND ElementGroup_NUMB = @ElementGroup_NUMB)
            AND (LTRIM(RTRIM(Element_Value)) != ''
                 AND Element_Value IS NOT NULL);

         IF @Ln_SelectedElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
            AND @Ln_SelectedElementsCount_NUMB = 0
          BEGIN
           INSERT INTO @NoticeErrors_P1
           SELECT DISTINCT
                  V.Element_NAME,
                  'E1081' Msg_CODE,
                  'No. of Check Boxes in the Group: ' + CAST(@ElementGroup_NUMB AS VARCHAR) + ' to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) + ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR) + ', but Checked are: ' + CAST(@Ln_SelectedElementsCount_NUMB AS VARCHAR) Error_DESC
             FROM NDEL_Y1 V
            WHERE v.Input_CODE = 'O'
              AND v.Notice_ID = @Lc_Notice_ID
              AND Element_NAME LIKE 'option_%'
              AND v.ElementGroup_NUMB = @ElementGroup_NUMB
              AND (@Lc_Notice_ID NOT IN ('INT-01', 'INT-04', 'INT-09', 'LEG-154', 'CSI-05'))
              AND (EXISTS (SELECT 1
                             FROM @NoticeElementsData_P1
                            WHERE Element_NAME = v.Element_NAME
                              AND (LTRIM(RTRIM(Element_Value)) = ''
                                    OR Element_Value IS NULL))
                    OR NOT EXISTS(SELECT 1
                                    FROM @NoticeElementsData_P1
                                   WHERE Element_NAME = v.Element_NAME));
          END

         /* Check for the errors in the input xml sent from UI, since we list elements are not been generated 
         when batch_gen_notices$sp_generate_notice is called from batch_common$sp_insert_activity */
         IF @Lc_Notice_ID IN ('INT-01', 'INT-04', 'INT-09', 'LEG-154', 'CSI-05')
          BEGIN
           SELECT @Ls_ParentElement_NAME = Element_NAME
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Seq_NUMB = (SELECT DISTINCT
                                     ParentSeq_NUMB
                                FROM NDEL_Y1
                               WHERE Notice_ID = @Lc_Notice_ID
                                 AND ElementGroup_NUMB = @ElementGroup_NUMB);

           SELECT @Ls_Xml_TEXT = Element_VALUE
             FROM @NoticeElementsData_P1
            WHERE Element_NAME = @Ls_ParentElement_NAME;

           SET @Ln_PositionStart_numb = 0;
           SET @Ln_PositionEnd_NUMB = 0;
           SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_ParentElement_NAME + ' count=', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_ParentElement_NAME + ' count=') + 1;
           SET @Ln_PositionEnd_NUMB = CHARINDEX('>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) - 1;
        
		   --13424 - NNRQ - Run-time Error Fix - Start
           SET @Ln_RowCount_NUMB = ISNULL(CAST(REPLACE(REPLACE(LTRIM(RTRIM(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_numb, @Ln_PositionEnd_numb - @Ln_PositionStart_numb))),'"',''),'=','') AS NUMERIC), 0);
           SET @Ln_Counter_NUMB = 1

			IF @Ln_RowCount_NUMB = 0 AND @Lc_Notice_ID = 'LEG-154' 
			BEGIN
				SELECT @Ln_RowCount_NUMB = COUNT(1) FROM BATCH_GEN_NOTICES$SF_GET_Leg154DEPENDENT_DETAILS (@Ln_Case_IDNO,@Lc_Worker_ID,@Ld_Run_DATE);
			END
		  --13424 - NNRQ - Run-time Error Fix - End
           WHILE (@Ln_Counter_NUMB <= @Ln_RowCount_NUMB)
            BEGIN
             SET @Ln_PositionStart_numb = CHARINDEX('<row>', @Ls_Xml_TEXT, @Ln_PositionStart_numb) + LEN('<row>');
             SET @Ln_SelectedElementsCount_NUMB = 0;
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND ElementGroup_NUMB = @ElementGroup_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_numb = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_numb = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_numb, @Ln_PositionEnd_numb - @Ln_PositionStart_numb)) != 0
                  BEGIN
                   SET @Ln_SelectedElementsCount_NUMB = @Ln_SelectedElementsCount_NUMB + 1;
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;

             IF @Ln_SelectedElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
                AND @Ln_SelectedElementsCount_NUMB = 0
              BEGIN
               SET @XmlRequiredElements_CUR = CURSOR
               FOR SELECT Element_NAME
                     FROM NDEL_Y1
                    WHERE Notice_ID = @Lc_Notice_ID
                      AND Input_CODE = 'O'
                      AND ElementGroup_NUMB = @ElementGroup_NUMB;

               OPEN @XmlRequiredElements_CUR;

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

               WHILE @@FETCH_STATUS = 0
                BEGIN
                 INSERT INTO @NoticeErrors_P1
                      VALUES (@Ls_Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                              'E1081',
                              'No. of Check Boxes in the Group: ' + CAST(@ElementGroup_NUMB AS VARCHAR) + ' to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) + ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR) + ', but Checked are: ' + CAST(@Ln_SelectedElementsCount_NUMB AS VARCHAR) );

                 FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
                END

               CLOSE @XmlRequiredElements_CUR;

               DEALLOCATE @XmlRequiredElements_CUR;
              END

             SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
            END
          END

         FETCH NEXT FROM @GetRequired_Element_CUR INTO @ElementGroup_NUMB;
        END

       CLOSE @GetRequired_Element_CUR;

       DEALLOCATE @GetRequired_Element_CUR;
      END

     -- End of Handling errors for option groups  
     -- Start of Handling Errors for option not in groups
     SET @RequiredElements_CUR = CURSOR
     FOR (SELECT Element_NAME
            FROM NDEL_Y1
           WHERE Notice_ID = @Lc_Notice_ID
             AND ElementGroup_NUMB = 0
             AND OptionParentSeq_NUMB = 0
             AND Input_CODE = 'O'
             AND Element_NAME LIKE 'option_%'
             AND Required_INDC = 'Y');

     OPEN @RequiredElements_CUR;

     FETCH NEXT FROM @RequiredElements_CUR INTO @Ls_RequiredInputParam_TEXT;

     WHILE @@FETCH_STATUS = 0
      BEGIN
       SET @Ls_RequiredInputParamValue_TEXT = (SELECT Element_VALUE
                                                 FROM @NoticeElementsData_P1
                                                WHERE ELEment_NAME = @Ls_RequiredInputParam_TEXT);

       IF @Ls_RequiredInputParamValue_TEXT IS NULL
           OR LTRIM(RTRIM(@Ls_RequiredInputParamValue_TEXT)) = ''
        BEGIN
         INSERT INTO @NoticeErrors_P1
                     (Element_NAME,
                      Error_CODE,
                      Error_DESC)
         SELECT @Ls_RequiredInputParam_TEXT AS Parameter_NAME,
                'E0076' AS Error_CODE,
                @Ls_e0076desc_text AS Error_DESC;
        END

       FETCH NEXT FROM @RequiredElements_CUR INTO @Ls_RequiredInputParam_TEXT;
      END

     CLOSE @RequiredElements_CUR;

     DEALLOCATE @RequiredElements_CUR;

     -- End of Handling Errors for option not in groups
     -- Start of Handling errors for dependency options groups
     SET @GetRequired_Element_CUR = CURSOR
     FOR SELECT OptionParentSeq_NUMB
           FROM NDEL_Y1
          WHERE OptionParentSeq_NUMB <> 0
            AND ElementGroup_NUMB != 0
            AND Notice_ID = @Lc_Notice_ID
            AND Input_CODE = 'O'
            AND Element_NAME LIKE 'option_%'
          GROUP BY OptionParentSeq_NUMB;

     OPEN @GetRequired_Element_CUR;

     FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;

     WHILE @@FETCH_STATUS = 0
      BEGIN
       SET @Ls_SelectedElement_VALUE = '';

       -- if group number is given in Parent sequence number, so what is the min and max count of that parent group
       SELECT TOP 1 @Ln_ParentElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
                    @Ln_ParentElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
         FROM NDEL_Y1
        WHERE Notice_ID = @Lc_Notice_ID
          AND Input_CODE = 'O'
          AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

       SELECT @Ln_OptionsInSetCount_NUMB = COUNT(1)
         FROM NDEL_Y1
        WHERE Notice_ID = @Lc_Notice_ID
          AND Input_CODE = 'O'
          AND OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
          AND ParentSeq_NUMB != 0;

       IF @Ln_OptionsInSetCount_NUMB = 0
        BEGIN
         /* if group number is given in Parent sequence number, Fetching the No. of Elements of the parent group 
            that has the data in @NoticeElementsData_P1 table */
         SELECT @Ln_ParentGroupSelectedElementsCount_NUMB = COUNT(Element_NAME)
           FROM @NoticeElementsData_P1
          WHERE Element_NAME IN (SELECT Element_NAME
                                   FROM NDEL_Y1
                                  WHERE Notice_ID = @Lc_Notice_ID
                                    AND Input_CODE = 'O'
                                    AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB)
            AND (LTRIM(RTRIM(Element_Value)) != ''
                 AND Element_Value IS NOT NULL);

         SELECT @Ln_ElementGroup_NUMB = MAX(ElementGroup_NUMB)
           FROM NDEL_Y1
          WHERE Notice_ID = @Lc_Notice_ID
            AND Input_CODE = 'O'
            AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
            AND ElementGroupMinRequired_NUMB = 1
            AND ElementGroupMaxRequired_NUMB = 1;

         IF @Ln_ElementGroup_NUMB != 0
            AND @Ln_ElementGroup_NUMB IS NOT NULL
          BEGIN
           -- If sequence number is given as parent sequence number, fetching the value of the parent
           SELECT @Ls_SelectedElement_VALUE = LTRIM(RTRIM(Element_VALUE))
             FROM @NoticeElementsData_P1
            WHERE Element_NAME IN (SELECT Element_NAME
                                     FROM NDEL_Y1
                                    WHERE Notice_ID = @Lc_Notice_ID
                                      AND Input_CODE = 'O'
                                      AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB)
              AND (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL);
          END

         IF @Ls_SelectedElement_VALUE = 'X'
          BEGIN
           SELECT @Ls_SelectedElement_VALUE = LTRIM(RTRIM(Element_NAME))
             FROM @NoticeElementsData_P1
            WHERE Element_NAME IN (SELECT Element_NAME
                                     FROM NDEL_Y1
                                    WHERE Notice_ID = @Lc_Notice_ID
                                      AND Input_CODE = 'O'
                                      AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB)
              AND (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL);
          END

         -- If sequence number is given as parent sequence number, fetching whether the parent has the value
         IF @Ln_ElementGroup_NUMB != 0
            AND @Ln_ElementGroup_NUMB IS NOT NULL --AND @Ln_NonOptionElementInGroup_COUNT = 0
          BEGIN
           SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
              AND Element_NAME = @Ls_SelectedElement_VALUE;
          END
         ELSE
          BEGIN
           SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
             FROM @NoticeElementsData_P1
            WHERE (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL)
              AND Element_NAME = (SELECT Element_NAME
                                    FROM NDEL_Y1
                                   WHERE Notice_ID = @Lc_Notice_ID
                                     AND Input_CODE = 'O'
                                     AND Seq_NUMB = @Ln_OptionParentSeq_NUMB);
          END

         ------------------------
         -- Sub Groups For Child Elements
         SET @RequiredElements_CUR = CURSOR
         FOR SELECT ElementGroup_NUMB
               FROM NDEL_Y1
              WHERE ElementGroup_NUMB <> 0
                AND OptionParentSeq_NUMB != 0
                AND Notice_ID = @Lc_Notice_ID
                AND Element_NAME LIKE 'option_%'
                AND OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
              GROUP BY ElementGroup_NUMB;

         OPEN @RequiredElements_CUR;

         FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB;

         WHILE @@FETCH_STATUS = 0
          BEGIN
           -- Getting the min and max elements required among the child element group
           SELECT TOP 1 @Ln_ElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
                        @Ln_ElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND ElementGroup_NUMB = @ElementGroup_NUMB;

           -- Fetching the Child Elements number which has the data in @NoticeElementsData_P1 table in a elements group
           SELECT @Ln_SelectedElementsCount_NUMB = COUNT(Element_NAME)
             FROM @NoticeElementsData_P1
            WHERE Element_NAME IN (SELECT Element_NAME
                                     FROM NDEL_Y1
                                    WHERE Notice_ID = @Lc_Notice_ID
                                      AND Input_CODE = 'O'
                                      AND ElementGroup_NUMB = @ElementGroup_NUMB)
              AND (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL);

           IF ((@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                OR @Ln_ParentSelectedElementCount_NUMB > 0)
              AND ((@Ln_SelectedElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
                    AND @Ln_SelectedElementsCount_NUMB != 0)
                    OR @Ln_SelectedElementsCount_NUMB = 0)
            BEGIN
             INSERT INTO @NoticeErrors_P1
             SELECT DISTINCT
                    V.Element_NAME,
                    'E1081' Msg_CODE,
                    'No. of Check Boxes in the Group: ' + CAST(@ElementGroup_NUMB AS VARCHAR) + ' to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) + ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR) + ', but Checked are: ' + CAST(@Ln_SelectedElementsCount_NUMB AS VARCHAR) Error_DESC
               FROM NDEL_Y1 V
              WHERE v.Input_CODE = 'O'
                AND v.Notice_ID = @Lc_Notice_ID
                AND v.ElementGroup_NUMB = @ElementGroup_NUMB
                AND (EXISTS (SELECT 1
                               FROM @NoticeElementsData_P1
                              WHERE Element_NAME = v.Element_NAME
                                AND (LTRIM(RTRIM(Element_Value)) = ''
                                      OR Element_Value IS NULL))
                      OR NOT EXISTS(SELECT 1
                                      FROM @NoticeElementsData_P1
                                     WHERE Element_NAME = v.Element_NAME));
            END
           ELSE IF (((@Ln_ParentGroupSelectedElementsCount_NUMB NOT BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                 AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                 OR @Ln_ParentGroupSelectedElementsCount_NUMB = 0)
               AND @Ln_ParentSelectedElementCount_NUMB = 0)
              AND (@Ln_SelectedElementsCount_NUMB BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
                   AND @Ln_SelectedElementsCount_NUMB != 0)
            BEGIN
             SELECT @Ln_GroupElementCount_NUMB = COUNT(1)
               FROM NDEL_Y1
              WHERE Notice_ID = @Lc_Notice_ID
                AND Input_CODE = 'O'
                AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

             IF @Ln_GroupElementCount_NUMB != 0
              BEGIN
               INSERT INTO @NoticeErrors_P1
               SELECT DISTINCT
                      V.Element_NAME,
                      'E1081' Msg_CODE,
                      'Child Element is Checked, but Parent Element is not Checked 1' Error_DESC
                 FROM NDEL_Y1 V
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB
              END
             ELSE
              BEGIN
               INSERT INTO @NoticeErrors_P1
               SELECT DISTINCT
                      V.Element_NAME,
                      'E1081' Msg_CODE,
                      'Child Element is Checked, but Parent Element is not Checked 2' Error_DESC
                 FROM NDEL_Y1 V
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
              END
            END

           FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB;
          END

         CLOSE @RequiredElements_CUR;

         DEALLOCATE @RequiredElements_CUR;
        END
       ELSE -- Notice_ID IN ('INT-01', 'INT-04', 'INT-09', 'LEG-154', 'CSI-05')
        BEGIN
         SELECT @Ls_ParentElement_NAME = Element_NAME
           FROM NDEL_Y1
          WHERE Notice_ID = @Lc_Notice_ID
            AND Seq_NUMB = (SELECT DISTINCT
                                   ParentSeq_NUMB
                              FROM NDEL_Y1
                             WHERE Notice_ID = @Lc_Notice_ID
                               AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB);

         SELECT @Ls_Xml_TEXT = Element_VALUE
           FROM @NoticeElementsData_P1
          WHERE Element_NAME = @Ls_ParentElement_NAME;

         SET @Ln_PositionStart_numb = 0;
         SET @Ln_PositionEnd_NUMB = 0;
         SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_ParentElement_NAME + ' count=', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_ParentElement_NAME + ' count=') + 1;
         SET @Ln_PositionEnd_NUMB = CHARINDEX('>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) - 1;
		 --13424 - NNRQ - Run-time Error Fix - Start
         SET @Ln_RowCount_NUMB = ISNULL(CAST(REPLACE(REPLACE(LTRIM(RTRIM(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_numb, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB))),'"',''),'=','') AS NUMERIC), 0);
		 --13424 - NNRQ - Run-time Error Fix - End
         SET @Ln_Counter_NUMB = 1;

         WHILE (@Ln_Counter_NUMB <= @Ln_RowCount_NUMB)
          BEGIN
           SET @Ln_RowPositionStart_NUMB = CHARINDEX('<row>', @Ls_Xml_TEXT, @Ln_PositionStart_NUMB) + LEN('<row>');
           SET @Ln_ParentGroupSelectedElementsCount_NUMB = 0;
           SET @XmlRequiredElements_CUR = CURSOR
           FOR SELECT Element_NAME
                 FROM NDEL_Y1
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

           OPEN @XmlRequiredElements_CUR;

           FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

           WHILE @@FETCH_STATUS = 0
            BEGIN
             SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
             SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
             SET @Ln_PositionEnd_NUMB = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

             IF @Ln_PositionEnd_NUMB != 0
              BEGIN
               IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)) != 0
                BEGIN
                 SET @Ln_ParentGroupSelectedElementsCount_NUMB = @Ln_ParentGroupSelectedElementsCount_NUMB + 1;
                END
              END

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
            END

           CLOSE @XmlRequiredElements_CUR;

           DEALLOCATE @XmlRequiredElements_CUR;

           -- If the parent is a radio, the value is packed in one of element of the radio group
           SELECT @Ln_ElementGroup_NUMB = MAX(ElementGroup_NUMB)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
              AND ElementGroupMinRequired_NUMB = 1
              AND ElementGroupMaxRequired_NUMB = 1;

           SET @Ln_ParentSelectedElementCount_NUMB = 0;

           IF @Ln_ElementGroup_NUMB != 0
              AND @Ln_ElementGroup_NUMB IS NOT NULL
            BEGIN
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
               SET @Ln_positionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_numb = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF @Ln_ElementGroup_NUMB != 0
                    AND @Ln_ElementGroup_NUMB IS NOT NULL
                  BEGIN
                   SET @Ls_SelectedElement_VALUE = LTRIM(RTRIM(SUBSTRING(@Ls_Xml_TEXT, @Ln_positionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)));

                   IF LEN(@Ls_SelectedElement_VALUE) != 0
                    BEGIN
                     SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
                       FROM NDEL_Y1
                      WHERE Notice_ID = @Lc_Notice_ID
                        AND Input_CODE = 'O'
                        AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
                        AND Element_NAME = @Ls_SelectedElement_VALUE;
                    END
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;
            END
           ELSE
            BEGIN
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND Seq_NUMB = @Ln_OptionParentSeq_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
               SET @Ln_positionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_numb = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_positionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_positionStart_NUMB)) != 0
                  BEGIN
                   SET @Ln_ParentSelectedElementCount_NUMB = @Ln_ParentSelectedElementCount_NUMB + 1;
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;
            END

           ------------------------
           -- Sub Groups For Child Elements
           SET @RequiredElements_CUR = CURSOR
           FOR SELECT ElementGroup_NUMB
                 FROM NDEL_Y1
                WHERE ElementGroup_NUMB <> 0
                  AND OptionParentSeq_NUMB != 0
                  AND Notice_ID = @Lc_Notice_ID
                  AND Element_NAME LIKE 'option_%'
                  AND OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
                GROUP BY ElementGroup_NUMB;

           OPEN @RequiredElements_CUR;

           FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB;

           WHILE @@FETCH_STATUS = 0
            BEGIN
             -- Getting the min and max elements required among the child element group
             SELECT TOP 1 @Ln_ElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
                          @Ln_ElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
               FROM NDEL_Y1
              WHERE Notice_ID = @Lc_Notice_ID
                AND Input_CODE = 'O'
                AND ElementGroup_NUMB = @ElementGroup_NUMB;

             SET @Ln_SelectedElementsCount_NUMB = 0;
             -- Getting the elemnts of child group
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND ElementGroup_NUMB = @ElementGroup_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
               SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_NUMB = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)) != 0
                  BEGIN
                   SET @Ln_SelectedElementsCount_NUMB = @Ln_SelectedElementsCount_NUMB + 1;
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;

             IF ((@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                  AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                  OR @Ln_ParentSelectedElementCount_NUMB > 0)
                AND ((@Ln_SelectedElementsCount_NUMB NOT BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
                      AND @Ln_SelectedElementsCount_NUMB != 0)
                      OR @Ln_SelectedElementsCount_NUMB = 0)
              BEGIN
               INSERT INTO @NoticeErrors_P1
               SELECT DISTINCT
                      V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                      'E1081' Msg_CODE,
                      'No. of Check Boxes in the Group: ' + CAST(@ElementGroup_NUMB AS VARCHAR) + ' to be Checked are Minimum: ' + CAST(@Ln_ElementGroupMinRequired_NUMB AS VARCHAR) + ' And Maximum: ' + CAST(@Ln_ElementGroupMaxRequired_NUMB AS VARCHAR) + ', but Checked are: ' + CAST(@Ln_SelectedElementsCount_NUMB AS VARCHAR) Error_DESC
                 FROM NDEL_Y1 V
                WHERE v.Input_CODE = 'O'
                  AND v.Notice_ID = @Lc_Notice_ID
                  AND v.ElementGroup_NUMB = @ElementGroup_NUMB
                  AND (EXISTS (SELECT 1
                                 FROM @NoticeElementsData_P1
                                WHERE Element_NAME = v.Element_NAME
                                  AND (LTRIM(RTRIM(Element_Value)) = ''
                                        OR Element_Value IS NULL))
                        OR NOT EXISTS(SELECT 1
                                        FROM @NoticeElementsData_P1
                                       WHERE Element_NAME = v.Element_NAME));
              END
             ELSE IF (((@Ln_ParentGroupSelectedElementsCount_NUMB NOT BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                   AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                   OR @Ln_ParentGroupSelectedElementsCount_NUMB = 0)
                 AND @Ln_ParentSelectedElementCount_NUMB = 0)
                AND (@Ln_SelectedElementsCount_NUMB BETWEEN @Ln_ElementGroupMinRequired_NUMB AND @Ln_ElementGroupMaxRequired_NUMB
                     AND @Ln_SelectedElementsCount_NUMB != 0)
              BEGIN
               SELECT @Ln_GroupElementCount_NUMB = COUNT(1)
                 FROM NDEL_Y1
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

               IF @Ln_GroupElementCount_NUMB != 0
                BEGIN
                 INSERT INTO @NoticeErrors_P1
                 SELECT DISTINCT
                        V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                        'E1081' Msg_CODE,
                        'Child Element is Checked, but Parent Element is not Checked 1' Error_DESC
                   FROM NDEL_Y1 V
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;
                END
               ELSE
                BEGIN
                 INSERT INTO @NoticeErrors_P1
                 SELECT DISTINCT
                        V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                        'E1081' Msg_CODE,
                        'Child Element is Checked, but Parent Element is not Checked 2' Error_DESC
                   FROM NDEL_Y1 V
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
                END
              END

             FETCH NEXT FROM @RequiredElements_CUR INTO @ElementGroup_NUMB;
            END

           CLOSE @RequiredElements_CUR;

           DEALLOCATE @RequiredElements_CUR;

           SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
          END
        END

       FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;
      END

     CLOSE @GetRequired_Element_CUR;

     DEALLOCATE @GetRequired_Element_CUR;

     -- End of Handling errors for dependency options groups
     -- Start of Handling errors for dependency options not in groups
     SET @GetRequired_Element_CUR = CURSOR
     FOR SELECT OptionParentSeq_NUMB
           FROM NDEL_Y1
          WHERE OptionParentSeq_NUMB <> 0
            AND ElementGroup_NUMB = 0
            AND Notice_ID = @Lc_Notice_ID
            AND Input_CODE = 'O'
            AND Element_NAME LIKE 'option_%'
          GROUP BY OptionParentSeq_NUMB;

     OPEN @GetRequired_Element_CUR;

     FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB;

     WHILE @@FETCH_STATUS = 0
      BEGIN
       SET @Ls_SelectedElement_VALUE = '';

       -- if group number is given in Parent sequence number, so what is the min and max count of that parent group
       SELECT TOP 1 @Ln_ParentElementGroupMinRequired_NUMB = ISNULL(MAX(ElementGroupMinRequired_NUMB), 0),
                    @Ln_ParentElementGroupMaxRequired_NUMB = ISNULL(MAX(ElementGroupMaxRequired_NUMB), 0)
         FROM NDEL_Y1
        WHERE Notice_ID = @Lc_Notice_ID
          AND Input_CODE = 'O'
          AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

       SELECT @Ln_OptionsInSetCount_NUMB = COUNT(1)
         FROM NDEL_Y1
        WHERE Notice_ID = @Lc_Notice_ID
          AND Input_CODE = 'O'
          AND OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
          AND ParentSeq_NUMB != 0;

       IF @Ln_OptionsInSetCount_NUMB = 0
        BEGIN
         /* if group number is given in Parent sequence number, Fetching the No. of Elements of the parent group 
            that has the data in @NoticeElementsData_P1 table */
         SELECT @Ln_ParentGroupSelectedElementsCount_NUMB = COUNT(Element_NAME)
           FROM @NoticeElementsData_P1
          WHERE Element_NAME IN (SELECT Element_NAME
                                   FROM NDEL_Y1
                                  WHERE Notice_ID = @Lc_Notice_ID
                                    AND Input_CODE = 'O'
                                    AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB)
            AND (LTRIM(RTRIM(Element_Value)) != ''
                 AND Element_Value IS NOT NULL);

         SELECT @Ln_ElementGroup_NUMB = MAX(ElementGroup_NUMB)
           FROM NDEL_Y1
          WHERE Notice_ID = @Lc_Notice_ID
            AND Input_CODE = 'O'
            AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
            AND ElementGroupMinRequired_NUMB = 1
            AND ElementGroupMaxRequired_NUMB = 1;

         IF @Ln_ElementGroup_NUMB != 0
            AND @Ln_ElementGroup_NUMB IS NOT NULL
          BEGIN
           -- If sequence number is given as parent sequence number, fetching the value of the parent
           SELECT @Ls_SelectedElement_VALUE = LTRIM(RTRIM(Element_VALUE))
             FROM @NoticeElementsData_P1
            WHERE Element_NAME IN (SELECT Element_NAME
                                     FROM NDEL_Y1
                                    WHERE Notice_ID = @Lc_Notice_ID
                                      AND Input_CODE = 'O'
                                      AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB)
              AND (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL);
          END

         IF @Ls_SelectedElement_VALUE = 'X'
          BEGIN
           SELECT @Ls_SelectedElement_VALUE = LTRIM(RTRIM(Element_NAME))
             FROM @NoticeElementsData_P1
            WHERE Element_NAME IN (SELECT Element_NAME
                                     FROM NDEL_Y1
                                    WHERE Notice_ID = @Lc_Notice_ID
                                      AND Input_CODE = 'O'
                                      AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB)
              AND (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL);
          END

         -- If sequence number is given as parent sequence number, fetching whether the parent has the value
         IF @Ln_ElementGroup_NUMB != 0
            AND @Ln_ElementGroup_NUMB IS NOT NULL
          BEGIN
           SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
              AND Element_NAME = @Ls_SelectedElement_VALUE;
          END
         ELSE
          BEGIN
           SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
             FROM @NoticeElementsData_P1
            WHERE (LTRIM(RTRIM(Element_Value)) != ''
                   AND Element_Value IS NOT NULL)
              AND Element_NAME = (SELECT Element_NAME
                                    FROM NDEL_Y1
                                   WHERE Notice_ID = @Lc_Notice_ID
                                     AND Input_CODE = 'O'
                                     AND Seq_NUMB = @Ln_OptionParentSeq_NUMB);
          END

         SELECT @Ln_ElementCount_NUMB = COUNT(1)
           FROM NDEL_Y1 V
          WHERE v.Input_CODE = 'O'
            AND v.Notice_ID = @Lc_Notice_ID
            AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
            AND ElementGroup_NUMB = 0;

         SELECT @Ln_SelectedElementCount_NUMB = COUNT(1)
           FROM NDEL_Y1 V
          WHERE v.Input_CODE = 'O'
            AND v.Notice_ID = @Lc_Notice_ID
            AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
            AND ElementGroup_NUMB = 0
            AND (EXISTS (SELECT 1
                           FROM @NoticeElementsData_P1
                          WHERE Element_NAME = v.Element_NAME
                            AND (LTRIM(RTRIM(Element_Value)) != ''
                                 AND Element_Value IS NOT NULL)));

         IF ((@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
              AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
              OR @Ln_ParentSelectedElementCount_NUMB > 0)
            AND (@Ln_SelectedElementCount_NUMB = 0
                  OR @Ln_SelectedElementCount_NUMB != @Ln_ElementCount_NUMB)
          BEGIN
           INSERT INTO @NoticeErrors_P1
           SELECT DISTINCT
                  V.Element_NAME,
                  'E1081' Msg_CODE,
                  'Parent of this Element is Checked, So this Element Should be Entered 3a' Error_DESC
             FROM NDEL_Y1 V
            WHERE v.Input_CODE = 'O'
              AND v.Notice_ID = @Lc_Notice_ID
              AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
              AND ElementGroup_NUMB = 0
              AND (EXISTS (SELECT 1
                             FROM @NoticeElementsData_P1
                            WHERE Element_NAME = v.Element_NAME
                              AND (LTRIM(RTRIM(Element_Value)) = ''
                                    OR Element_Value IS NULL))
                    OR NOT EXISTS(SELECT 1
                                    FROM @NoticeElementsData_P1
                                   WHERE Element_NAME = v.Element_NAME));
          END
         ELSE IF (((@Ln_ParentGroupSelectedElementsCount_NUMB NOT BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
               AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
               OR @Ln_ParentGroupSelectedElementsCount_NUMB = 0)
             AND @Ln_ParentSelectedElementCount_NUMB = 0)
            AND (@Ln_SelectedElementCount_NUMB != 0
                 AND @Ln_SelectedElementCount_NUMB = @Ln_ElementCount_NUMB)
          BEGIN
           SELECT @Ln_GroupElementCount_NUMB = COUNT(1)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

           IF @Ln_GroupElementCount_NUMB != 0
            BEGIN
             INSERT INTO @NoticeErrors_P1
             SELECT DISTINCT
                    V.Element_NAME,
                    'E1081' Msg_CODE,
                    'Child Element is Checked, but Parent Element is not Checked 3' Error_DESC
               FROM NDEL_Y1 V
              WHERE Notice_ID = @Lc_Notice_ID
                AND Input_CODE = 'O'
                AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;
            END
           ELSE
            BEGIN
             INSERT INTO @NoticeErrors_P1
             SELECT DISTINCT
                    V.Element_NAME,
                    'E1081' Msg_CODE,
                    'Child Element is Checked, but Parent Element is not Checked 4' Error_DESC
               FROM NDEL_Y1 V
              WHERE Notice_ID = @Lc_Notice_ID
                AND Input_CODE = 'O'
                AND Seq_NUMB = @Ln_OptionParentSeq_NUMB;
            END
          END
        END
       ELSE --Notice_ID IN ('INT-01', 'INT-04', 'INT-09', 'LEG-154', 'CSI-05')
        BEGIN
         SELECT @Ls_ParentElement_NAME = Element_NAME
           FROM NDEL_Y1
          WHERE Notice_ID = @Lc_Notice_ID
            AND Seq_NUMB = (SELECT DISTINCT
                                   ParentSeq_NUMB
                              FROM NDEL_Y1
                             WHERE Notice_ID = @Lc_Notice_ID
                               AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB);

         SELECT @Ls_Xml_TEXT = Element_VALUE
           FROM @NoticeElementsData_P1
          WHERE Element_NAME = @Ls_ParentElement_NAME;

         SET @Ln_PositionStart_numb = 0;
         SET @Ln_PositionEnd_NUMB = 0;
         SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_ParentElement_NAME + ' count=', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_ParentElement_NAME + ' count=') + 1;
         SET @Ln_PositionEnd_NUMB = CHARINDEX('>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) - 1;
		 --13424 - NNRQ - Run-time Error Fix - Start
         SET @Ln_RowCount_NUMB = ISNULL(CAST(REPLACE(REPLACE(LTRIM(RTRIM(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_numb, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB))),'"',''),'=','') AS NUMERIC), 0);
		 --13424 - NNRQ - Run-time Error Fix - End
         SET @Ln_Counter_NUMB = 1

         WHILE (@Ln_Counter_NUMB <= @Ln_RowCount_NUMB)
          BEGIN
           SET @Ln_RowPositionStart_NUMB = CHARINDEX('<row>', @Ls_Xml_TEXT, @Ln_PositionStart_NUMB) + LEN('<row>');
           SET @Ln_ParentGroupSelectedElementsCount_NUMB = 0;
           SET @XmlRequiredElements_CUR = CURSOR
           FOR SELECT Element_NAME
                 FROM NDEL_Y1
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

           OPEN @XmlRequiredElements_CUR;

           FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

           WHILE @@FETCH_STATUS = 0
            BEGIN
             SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
             SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
             SET @Ln_PositionEnd_NUMB = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

             IF @Ln_PositionEnd_NUMB != 0
              BEGIN
               IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)) != 0
                BEGIN
                 SET @Ln_ParentGroupSelectedElementsCount_NUMB = @Ln_ParentGroupSelectedElementsCount_NUMB + 1;
                END
              END

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
            END

           CLOSE @XmlRequiredElements_CUR;

           DEALLOCATE @XmlRequiredElements_CUR;

           -- If the parent is a radio, the value is packed in one of element of the radio group
           SELECT @Ln_ElementGroup_NUMB = MAX(ElementGroup_NUMB)
             FROM NDEL_Y1
            WHERE Notice_ID = @Lc_Notice_ID
              AND Input_CODE = 'O'
              AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
              AND ElementGroupMinRequired_NUMB = 1
              AND ElementGroupMaxRequired_NUMB = 1;

           SET @Ln_ParentSelectedElementCount_NUMB = 0;

           IF @Ln_ElementGroup_NUMB != 0
              AND @Ln_ElementGroup_NUMB IS NOT NULL
            BEGIN
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND ElementGroup_NUMB = @Ln_ElementGroup_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
               SET @Ln_positionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_numb = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF @Ln_ElementGroup_NUMB != 0
                    AND @Ln_ElementGroup_NUMB IS NOT NULL
                  BEGIN
                   SET @Ls_SelectedElement_VALUE = LTRIM(RTRIM(SUBSTRING(@Ls_Xml_TEXT, @Ln_positionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)));

                   IF LEN(@Ls_SelectedElement_VALUE) != 0
                    BEGIN
                     SELECT @Ln_ParentSelectedElementCount_NUMB = COUNT(1)
                       FROM NDEL_Y1
                      WHERE Notice_ID = @Lc_Notice_ID
                        AND Input_CODE = 'O'
                        AND Seq_NUMB = @Ln_OptionParentSeq_NUMB
                        AND Element_NAME = @Ls_SelectedElement_VALUE;
                    END
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;
            END
           ELSE
            BEGIN
             SET @XmlRequiredElements_CUR = CURSOR
             FOR SELECT Element_NAME
                   FROM NDEL_Y1
                  WHERE Notice_ID = @Lc_Notice_ID
                    AND Input_CODE = 'O'
                    AND Seq_NUMB = @Ln_OptionParentSeq_NUMB;

             OPEN @XmlRequiredElements_CUR;

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

             WHILE @@FETCH_STATUS = 0
              BEGIN
               SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
               SET @Ln_positionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
               SET @Ln_PositionEnd_numb = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

               IF @Ln_PositionEnd_NUMB != 0
                BEGIN
                 IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_positionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_positionStart_NUMB)) != 0
                  BEGIN
                   SET @Ln_ParentSelectedElementCount_NUMB = @Ln_ParentSelectedElementCount_NUMB + 1;
                  END
                END

               FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
              END

             CLOSE @XmlRequiredElements_CUR;

             DEALLOCATE @XmlRequiredElements_CUR;
            END

           SET @Ln_SelectedElementCount_NUMB = 0;
           SET @Ln_ElementCount_NUMB = 0;

           DELETE FROM @SelectedElements;

           SET @XmlRequiredElements_CUR = CURSOR
           FOR SELECT Element_NAME
                 FROM NDEL_Y1 V
                WHERE v.Input_CODE = 'O'
                  AND v.Notice_ID = @Lc_Notice_ID
                  AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
                  AND ElementGroup_NUMB = 0;

           OPEN @XmlRequiredElements_CUR;

           FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;

           WHILE @@FETCH_STATUS = 0
            BEGIN
             SET @Ln_ElementCount_NUMB = @Ln_ElementCount_NUMB + 1;
             SET @Ln_PositionStart_NUMB = @Ln_RowPositionStart_NUMB;
             SET @Ln_PositionStart_NUMB = CHARINDEX('<' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB) + LEN('<' + @Ls_Element_NAME + '>');
             SET @Ln_PositionEnd_NUMB = CHARINDEX('</' + @Ls_Element_NAME + '>', @Ls_Xml_TEXT, @Ln_positionStart_NUMB);

             IF @Ln_PositionEnd_NUMB != 0
              BEGIN
               IF LEN(SUBSTRING(@Ls_Xml_TEXT, @Ln_PositionStart_NUMB, @Ln_PositionEnd_NUMB - @Ln_PositionStart_NUMB)) != 0
                BEGIN
                 SET @Ln_SelectedElementCount_NUMB = @Ln_SelectedElementCount_NUMB + 1;

                 INSERT INTO @SelectedElements
                      VALUES(@Ls_Element_NAME);
                END
              END

             FETCH NEXT FROM @XmlRequiredElements_CUR INTO @Ls_Element_NAME;
            END

           CLOSE @XmlRequiredElements_CUR;

           DEALLOCATE @XmlRequiredElements_CUR;

           IF ((@Ln_ParentGroupSelectedElementsCount_NUMB BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                OR @Ln_ParentSelectedElementCount_NUMB > 0)
              AND (@Ln_SelectedElementCount_NUMB = 0
                    OR @Ln_SelectedElementCount_NUMB != @Ln_ElementCount_NUMB)
            BEGIN
             INSERT INTO @NoticeErrors_P1
             SELECT DISTINCT
                    V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                    'E1081' Msg_CODE,
                    'Parent of this Element is Checked, So this Element Should be Entered 4a' Error_DESC
               FROM NDEL_Y1 V
              WHERE v.Input_CODE = 'O'
                AND v.Notice_ID = @Lc_Notice_ID
                AND v.OptionParentSeq_NUMB = @Ln_OptionParentSeq_NUMB
                AND ElementGroup_NUMB = 0
                AND V.Element_NAME NOT IN (SELECT Element_NAME
                                             FROM @SelectedElements);
            END
           ELSE IF (((@Ln_ParentGroupSelectedElementsCount_NUMB NOT BETWEEN @Ln_ParentElementGroupMinRequired_NUMB AND @Ln_ParentElementGroupMaxRequired_NUMB
                 AND @Ln_ParentGroupSelectedElementsCount_NUMB != 0)
                 OR @Ln_ParentGroupSelectedElementsCount_NUMB = 0)
               AND @Ln_ParentSelectedElementCount_NUMB = 0)
              AND (@Ln_SelectedElementCount_NUMB != 0
                   AND @Ln_SelectedElementCount_NUMB = @Ln_ElementCount_NUMB)
            BEGIN
             SELECT @Ln_GroupElementCount_NUMB = COUNT(1)
               FROM NDEL_Y1
              WHERE Notice_ID = @Lc_Notice_ID
                AND Input_CODE = 'O'
                AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;

             IF @Ln_GroupElementCount_NUMB != 0
              BEGIN
               INSERT INTO @NoticeErrors_P1
               SELECT DISTINCT
                      V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                      'E1081' Msg_CODE,
                      'Child Element is Checked, but Parent Element is not Checked 3' Error_DESC
                 FROM NDEL_Y1 V
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND ElementGroup_NUMB = @Ln_OptionParentSeq_NUMB;
              END
             ELSE
              BEGIN
               INSERT INTO @NoticeErrors_P1
               SELECT DISTINCT
                      V.Element_NAME + ':' + CONVERT(VARCHAR, @Ln_Counter_NUMB),
                      'E1081' Msg_CODE,
                      'Child Element is Checked, but Parent Element is not Checked 4' Error_DESC
                 FROM NDEL_Y1 V
                WHERE Notice_ID = @Lc_Notice_ID
                  AND Input_CODE = 'O'
                  AND Seq_NUMB = @Ln_OptionParentSeq_NUMB;
              END
            END

           SET @Ln_Counter_NUMB = @Ln_Counter_NUMB + 1;
          END
        END

       FETCH NEXT FROM @GetRequired_Element_CUR INTO @Ln_OptionParentSeq_NUMB
      END

     CLOSE @GetRequired_Element_CUR

     DEALLOCATE @GetRequired_Element_CUR;

     -- End of Handling errors for dependency options not in groups
     -- Start of Handling Errors for elements not having procedures
     INSERT INTO @NoticeErrors_P1
     SELECT DISTINCT
            V.Element_NAME,
            'E0058' Msg_CODE,
            @Ls_e0058desc_text Error_DESC
       FROM NDEL_Y1 V
      WHERE v.Input_CODE = 'O'
        AND v.Required_INDC = 'Y'
        AND v.Notice_ID = @Lc_Notice_ID
        AND v.Procedure_NAME = ' '
        AND Element_NAME NOT LIKE 'option_%'
        AND v.ParentSeq_NUMB = 0
        AND NOT EXISTS (SELECT 1
                          FROM RARE_Y1
                         WHERE ActivityMajor_CODE = @Lc_ActivityMajor_CODE
                           AND ActivityMinor_CODE = @Lc_ActivityMinor_CODE
                           AND Reason_CODE = @Lc_ReasonStatus_CODE
                           AND Required_INDC = @Lc_No_INDC
                           AND Element_NAME = V.Element_NAME)
        AND (EXISTS (SELECT 1
                       FROM @NoticeElementsData_P1
                      WHERE Element_NAME = v.Element_NAME
                        AND (LTRIM(RTRIM(Element_Value)) = ''
                              OR Element_Value IS NULL))
              OR NOT EXISTS(SELECT 1
                              FROM @NoticeElementsData_P1
                             WHERE Element_NAME = v.Element_NAME));

     SELECT @Ls_Esign_Title_Text = Element_Value
       FROM @NoticeElementsData_P1
      WHERE Element_NAME = 'esign_login_worker_title'

     IF @Ls_Esign_Title_Text = 'Deputy Attorney General'
      BEGIN
       DELETE FROM @NoticeErrors_P1
        WHERE Element_NAME IN('esignnotary_text', 'estampnotary_text');
      END
    -- End of Handling Errors for elements not having procedures
    END

   /*End of error handling for notices (Inserting into @NoticeErrors_P1)*/
   SET @Ln_NonRecipientCount_NUMB = (SELECT COUNT(*) AS row_NUM
                                       FROM @NoticeErrors_P1 V
                                      WHERE Element_Name NOT IN (SELECT Element_name
                                                                   FROM NDEL_Y1
                                                                  WHERE Notice_ID = @Lc_Notice_ID
                                                                    AND Element_NAME LIKE 'recipient_%')
                                        AND Element_NAME NOT IN('Swks_Member_IDNO', 'hearing_officer', 'DT_HEARING', 'HEARING_TIME',
                                                                'Location_IDNO', 'sch_cnty_selection_code', 'dt_oldsch_hearing', 'hearing_officer_name',
                                                                'iwo_freq_payback_text', 'iwo_ind_arrears_yes_code', 'iwo_freq_md_text', 'iwo_freq_ss_text')
                                        AND (Element_NAME NOT LIKE 'GENETIC_%'
                                              OR Element_NAME IN('genetic_result_positive_code', 'genetic_result_negative_code'))
                                        AND NOT EXISTS (SELECT 1
                                                          FROM RARE_Y1
                                                         WHERE ActivityMajor_CODE = @Lc_ActivityMajor_CODE
                                                           AND ActivityMinor_CODE = @Lc_ActivityMinor_CODE
                                                           AND Reason_CODE = @Lc_ReasonStatus_CODE
                                                           AND Required_INDC = @Lc_No_INDC
                                                           AND Element_NAME = V.Element_NAME));
   SET @Ln_RecipientCount_NUMB = (SELECT COUNT(*) AS row_NUM
                                    FROM @NoticeErrors_P1
                                   WHERE Element_Name IN (SELECT Element_name
                                                            FROM NDEL_Y1
                                                           WHERE Notice_ID = @Lc_Notice_ID
                                                             AND Element_NAME LIKE 'recipient_%'));

   IF @Ln_NonRecipientCount_NUMB > 0
    BEGIN
     SET @Ac_Msg_CODE = 'E1081';
    END
   ELSE IF @Ln_RecipientCount_NUMB > 0
    BEGIN
     SET @Ac_Msg_CODE = 'R';
    END

  /* Start of Generating Notice XML */
   /* Checks if the element in @NoticeElementsData_P1 table exists in NDEL_Y1 and frames    
      XML for the elements that are in @NoticeElementsData_P1 if the element exists in NDEL_Y1    */
   SELECT @Ls_Output_TEXT = COALESCE(@Ls_Output_TEXT, '') + '<' + a.Element_NAME + '>' + ISNULL(a.Element_Value, '') + '</' + a.Element_NAME + '>'
     FROM (SELECT Element_NAME,
                  ISNULL(T.Element_VALUE, '') Element_VALUE
             FROM @NoticeElementsData_P1 T
            WHERE EXISTS (SELECT 1
                            FROM NDEL_Y1 V
                           WHERE v.Element_NAME = T.Element_NAME
                             AND v.Input_CODE = 'O'
                             AND v.TypeElement_CODE <> 'M'
                             AND v.Element_NAME NOT LIKE 'option_%'
                             AND v.Notice_ID = @Lc_Notice_ID
                             AND NOT EXISTS(SELECT 1
                                              FROM NDEL_Y1
                                             WHERE Seq_NUMB = v.ParentSeq_NUMB
                                               AND TypeElement_CODE = 'M'))) a;

   SELECT @Ls_EmptyTagList_TEXT = COALESCE(@Ls_EmptyTagList_TEXT, '') + '<' + LOWER(v.Element_NAME) + '>' + '' + '</' + LOWER(v.Element_NAME) + '>'
     FROM NDEL_Y1 v
    WHERE v.Input_CODE = 'O'
      AND v.Notice_ID = @Lc_Notice_ID
      AND v.Element_NAME NOT LIKE 'option_%'
      AND NOT EXISTS(SELECT 1
                       FROM @NoticeElementsData_P1
                      WHERE Element_NAME = v.Element_NAME)
      AND v.TypeElement_CODE <> 'M'
      AND NOT EXISTS(SELECT 1
                       FROM NDEL_Y1
                      WHERE Seq_NUMB = v.ParentSeq_NUMB
                        AND TypeElement_CODE = 'M');

   SELECT @Ls_OutputOption_TEXT = COALESCE(@Ls_OutputOption_TEXT, '') + '<' + a.Element_NAME + '>' + a.Element_Value + '</' + a.Element_NAME + '>'
     FROM (SELECT Element_NAME,
                  ISNULL(T.Element_VALUE, '') Element_VALUE
             FROM @NoticeElementsData_P1 T
            WHERE EXISTS (SELECT 1
                            FROM NDEL_Y1 V
                           WHERE v.Element_NAME = T.Element_NAME
                             AND V.Input_CODE = 'O'
                             AND Element_NAME LIKE 'option_%'
                             AND ParentSeq_numb = 0
                             AND Notice_ID = @Lc_Notice_ID)) a;

   SET @Ls_Output_TEXT = ISNULL(@Ls_Output_TEXT, '') + ISNULL(@Ls_OutputOption_TEXT, '') + ISNULL(@Ls_EmptyTagList_TEXT, '');
   SET @As_Result_TEXT = @Ls_Output_TEXT + LTRIM(RTRIM(ISNULL(@As_Subelements_TEXT, '')));
  /* End of Generating Notice XML */
   /* Start of Generating Error XML */
   SET @Ln_ErrorCount_NUMB = (SELECT COUNT(*)
                                FROM @NoticeErrors_P1)

   IF @Ln_ErrorCount_NUMB > 0
    BEGIN
     -- Making all the elements to lower case to generate the xml elements in lower case
     UPDATE @NoticeErrors_P1
        SET Element_Name = LOWER(Element_Name);

     IF @Lc_printMethod_CODE = 'V'
      BEGIN
       SET @Ls_Result_TEXT = CONVERT(VARCHAR(MAX), (SELECT element_name,
                                                           ISNULL(Error_CODE, '') AS error_code,
                                                           ISNULL(Error_DESC, '') AS error_desc
                                                      FROM @NoticeErrors_P1 V
                                                     WHERE Element_NAME NOT IN('Swks_Member_IDNO', 'hearing_officer', 'DT_HEARING', 'HEARING_TIME',
                                                                               'Location_IDNO', 'sch_cnty_selection_code', 'dt_oldsch_hearing', 'mapp_scan_order_indc')
                                                       AND Element_NAME NOT LIKE 'GENETIC_%'
                                                       AND NOT EXISTS (SELECT 1
                                                                         FROM RARE_Y1
                                                                        WHERE ActivityMajor_CODE = @Lc_ActivityMajor_CODE
                                                                          AND ActivityMinor_CODE = @Lc_ActivityMinor_CODE
                                                                          AND Reason_CODE = @Lc_ReasonStatus_CODE
                                                                          AND Required_INDC = @Lc_No_INDC
                                                                          AND Element_NAME = V.Element_NAME)
                                                    FOR XML PATH('row')));

       SELECT @As_DescriptionError_TEXT = ('<' + LOWER(LTRIM(RTRIM(@Lc_Notice_ID))) + '><errorlist count = ''' + LTRIM(RTRIM(CAST(@Ln_ErrorCount_NUMB AS CHAR))) + '''>' + @Ls_Result_TEXT + '</errorlist></' + LOWER(LTRIM(RTRIM(@Lc_Notice_ID))) + '>') --as test  
       TRUNCATE TABLE #NoticeErrors_P1

       INSERT INTO #NoticeErrors_P1
       SELECT *
         FROM @NoticeErrors_P1

       RETURN;
      END
     ELSE IF @Lc_printMethod_CODE != 'V'
      BEGIN
       SET @Ls_Result_TEXT = CONVERT(VARCHAR(MAX), (SELECT element_name,
                                                           ISNULL(Error_CODE, '') AS error_code,
                                                           ISNULL(Error_DESC, '') AS error_desc
                                                      FROM @NoticeErrors_P1 V
                                                     WHERE NOT EXISTS (SELECT 1
                                                                         FROM RARE_Y1
                                                                        WHERE ActivityMajor_CODE = @Lc_ActivityMajor_CODE
                                                                          AND ActivityMinor_CODE = @Lc_ActivityMinor_CODE
                                                                          AND Reason_CODE = @Lc_ReasonStatus_CODE
                                                                          AND Required_INDC = @Lc_No_INDC
                                                                          AND Element_NAME = V.Element_NAME)
                                                    FOR XML PATH('row')));

       SELECT @As_DescriptionError_TEXT = ('<' + LOWER(LTRIM(RTRIM(@Lc_Notice_ID))) + '><errorlist count = ''' + LTRIM(RTRIM(CAST(@Ln_ErrorCount_NUMB AS CHAR))) + '''>' + @Ls_Result_TEXT + '</errorlist></' + LOWER(LTRIM(RTRIM(@Lc_Notice_ID))) + '>') --as test  
       RETURN;
      END
    END

   /* End of Generating Error XML */
   IF @As_Result_TEXT = ''
    BEGIN
     RAISERROR(50001,16,1);
    END
   ELSE
    BEGIN
     SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
    END
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ls_Sql_TEXT='Error building XML  '

   IF ERROR_NUMBER () = 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE(), 'BATCH_GEN_NOTICES$SP_BUILD_XML') + ' PROCEDURE' + '. Error DESC - ' + @Ls_ErrorDesc_TEXT + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END
   ELSE
    BEGIN
     SET @Ls_DescriptionError_TEXT = 'Error IN ' + ISNULL(ERROR_PROCEDURE (), 'BATCH_GEN_NOTICES$SP_BUILD_XML') + ' PROCEDURE' + '. Error DESC - ' + SUBSTRING (ERROR_MESSAGE (), 1, 200) + '. Error Line No - ' + CAST (ERROR_LINE () AS VARCHAR) + '. Error Number - ' + CAST (ERROR_NUMBER () AS VARCHAR) + '. Error EXECUTE Location - ' + @Ls_Sql_TEXT + '. Error List KEY - ' + @Ls_Sqldata_TEXT;
    END

   SET @As_DescriptionError_TEXT=@Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
