/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_SELECT_RESPONDENT_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_SELECT_RESPONDENT_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_SELECT_RESPONDENT_DTLS] (
 @An_Case_IDNO              NUMERIC(6),
 @Ac_Notice_ID              CHAR(8),
 @An_MemberMci_IDNO         NUMERIC(10),
 @An_Office_IDNO            NUMERIC(3),
 @Ac_File_ID                CHAR(15),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @An_TransHeader_IDNO       NUMERIC(12),
 @Ac_InitiatingFips_ID      CHAR(7),
 @Ac_Recipient_CODE         CHAR(2),
 @Ac_Recipient_ID           CHAR(10),
 @Ac_TransOtherState_INDC   CHAR(1),
 @Ac_TypeAddress_CODE       CHAR(1),
 @Ad_Run_DATE               DATE,
 @Ac_Msg_CODE               CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT  VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_RelationshipCaseCp_TEXT CHAR(1) = 'C',
          @Lc_TransOtherStateI1_INDC  CHAR(1) = 'I',
		  @Lc_StatusOpen_CODE		  CHAR(1) = 'O',
          @Lc_RecdetOtherState_CODE   CHAR(2) = 'OS',
          @Lc_InStateFips_CODE        CHAR(2) = '10',
          @Lc_SubTypeAddress_CODE     CHAR(3) = 'SDU',
          @Lc_TypeAddressSta_CODE     CHAR(3) = 'STA',
          @Lc_SubTypeAddressCrg_CODE  CHAR(3) = 'CRG',
          @Lc_InStateCentralFips_CODE CHAR(7) = '1000000',
          @Ls_Procedure_NAME          VARCHAR(75) = 'BATCH_GEN_NOTICES$SP_SELECT_RESPONDENT_DTLS';
  DECLARE @Lc_TempStateFips_CODE    CHAR(2)= '',
          @Lc_Fips_CODE             CHAR(2)='',
          @Lc_RecipientIcas_ID      CHAR(7)='',
          @Lc_AssignedFips_CODE		CHAR(7),	
          @Ls_Sql_TEXT              VARCHAR(200),
          @Ls_Sqldata_TEXT          VARCHAR(400),
          @Ls_DescriptionError_TEXT VARCHAR(4000);

  /* @An_MemberMci_IDNO expects RespondentMci_IDNO value */
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ac_TransOtherState_INDC = ISNULL(@Ac_TransOtherState_INDC, 'O');
   
   SELECT @Lc_AssignedFips_CODE = c.AssignedFips_CODE 
				FROM CASE_Y1 c
				WHERE c.Case_IDNO = @An_Case_IDNO
				AND c.StatusCase_CODE = @Lc_StatusOpen_CODE;	
				
   IF @Ac_Recipient_CODE = @Lc_RecdetOtherState_CODE --1
    BEGIN
     /* FOR Outgoing Transaction */
     IF @Ac_TransOtherState_INDC <> @Lc_TransOtherStateI1_INDC --2
      BEGIN
     
       SET @Lc_Fips_CODE = SUBSTRING(CONVERT(VARCHAR(10), @Ac_Recipient_ID), 1, 2);

       EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS
        @Ac_IVDOutOfStateFips_CODE = @Lc_Fips_CODE,
        @As_Prefix_TEXT            = 'TO',
        @An_Case_IDNO              = @An_Case_IDNO,
        @Ac_Recipient_ID		   = @Ac_Recipient_ID,
        @An_MemberMci_IDNO         = @An_MemberMci_IDNO,
        @Ad_Run_DATE               = @Ad_Run_DATE,
        @Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT  = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

       
       SET @Lc_RecipientIcas_ID = (SELECT DISTINCT
                                          Element_Value
                                     FROM #NoticeElementsData_P1
                                    WHERE Element_name = 'TO_FIPS_CODE');
    
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
       SET @Ls_Sqldata_TEXT = 'Recipient_IDNO = ' + ISNULL(CAST(@Ac_Recipient_ID AS VARCHAR(10)), '');

       EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
        @Ac_Fips_CODE             = @Lc_RecipientIcas_ID,
        @As_Prefix_TEXT           = 'TO_AGENCY',
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END

                                    
       SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS';
       SET @Ls_Sqldata_TEXT = 'Fips_CODE = ' + ISNULL(@Lc_RecipientIcas_ID, '') + ', TypeAddressSta_CODE = ' + ISNULL(@Lc_TypeAddressSta_CODE, '') + ', SubTypeAddress_CODE = ' + ISNULL(@Lc_SubTypeAddress_CODE, '');

       EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS
        @Ac_StateFips_CODE        = @Lc_RecipientIcas_ID,    
        @Ac_TypeAddress_CODE      = @Lc_TypeAddressSta_CODE,
        @Ac_SubTypeAddress_CODE   = @Lc_SubTypeAddress_CODE,
        @As_Prefix_TEXT           = 'TO_AGENCY_SDU',
        @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
        @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

       IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
        BEGIN
         RAISERROR (50001,16,1);
        END
      END
     ELSE --2  /* FOR Incoming Transaction */
      BEGIN
       IF @Ac_InitiatingFips_ID IS NOT NULL
          AND @Ac_InitiatingFips_ID != ''
        BEGIN
         --SET @Lc_TempStateFips_CODE = SUBSTRING(@Ac_InitiatingFips_ID, 1, 2);

         IF @An_Case_IDNO IS NOT NULL
            AND @An_Case_IDNO != 0
          BEGIN
          			
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' +  ISNULL( CAST(@An_Case_IDNO AS VARCHAR(6)),'') + ', Fips_CODE = ' + ISNULL(CAST(@Lc_AssignedFips_CODE AS VARCHAR),'');
         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
         
         EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
         @Ac_Fips_CODE             = @Lc_AssignedFips_CODE,
         @As_Prefix_TEXT           = 'TO_AGENCY',
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
         
          IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
           BEGIN
            RAISERROR (50001,16,1);
           END
          END
         ELSE
          BEGIN
           SET @Ac_InitiatingFips_ID = @Lc_InStateCentralFips_CODE;
           SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS';
           SET @Ls_Sqldata_TEXT = 'StateFips_CODE = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', TypeAddress_CODE  = ' + @Lc_TypeAddressSta_CODE + ', SubTypeAddress_CODE = ' + @Lc_SubTypeAddressCrg_CODE;

           EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS
            @Ac_StateFips_CODE        = @Lc_InStateFips_CODE,
            @Ac_TypeAddress_CODE      = @Lc_TypeAddressSta_CODE,
            @Ac_SubTypeAddress_CODE   = @Lc_SubTypeAddressCrg_CODE,
            @As_Prefix_TEXT           = 'TO_AGENCY',
            @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

           IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END
          END

         
         IF (@An_Case_IDNO IS NOT NULL
            AND @An_Case_IDNO != 0)
             AND (@An_TransHeader_IDNO IS NULL 
				OR @An_TransHeader_IDNO = 0)
          BEGIN
           SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS';
           SET @Ls_Sqldata_TEXT = 'IVDOutOfStateFips_CODE = ' + ISNULL(@Lc_TempStateFips_CODE, '') + ', Case_IDNO = ' + CAST(ISNULL(@An_Case_IDNO, 0) AS VARCHAR(6)) + ', MemberMci_IDNO = ' + CAST(ISNULL(@An_MemberMci_IDNO, 0) AS VARCHAR(10)) + ', RUN_DATE = ' + CAST(@Ad_Run_DATE AS VARCHAR(10)) + ', Prefix_CODE = ' + 'To';

           EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS
            @Ac_IVDOutOfStateFips_CODE = @Lc_InStateFips_CODE,--@Lc_TempStateFips_CODE,
            @As_Prefix_TEXT            = 'TO',
            @An_Case_IDNO              = @An_Case_IDNO,
            @An_MemberMci_IDNO         = @An_MemberMci_IDNO,
            @Ad_Run_DATE               = @Ad_Run_DATE,
            @Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
            @As_DescriptionError_TEXT  = @As_DescriptionError_TEXT OUTPUT;

           IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
            BEGIN
             RAISERROR (50001,16,1);
            END
          END
         ELSE
          BEGIN
           INSERT INTO #NoticeElementsData_P1
                       (Element_NAME,
                        Element_Value)
           (SELECT Element_NAME,
                   Element_VALUE
              FROM(SELECT CONVERT(VARCHAR(100), IVDOutOfStateCase_ID) TO_IVDOutOfStateCase_ID,
                          CONVERT(VARCHAR(100), ToAgencyFips_IDNO) TO_Fips_CODE--,    
                     FROM (SELECT TOP 1
                           CASE
                                                               WHEN CAST(ISNULL(Case_IDNO, 0) AS CHAR) = '0'
                                                                THEN ''
                                                               ELSE CAST(CASE_IDNO AS CHAR)
                                                              END IVDOutOfStateCase_ID,
                                                              ISNULL(b.StateFips_CODE, '') + ISNULL(b.CountyFips_CODE, '') + ISNULL(b.OfficeFips_CODE, '') ToAgencyFips_IDNO
                             FROM CTHB_Y1 b
                            WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
                              AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                              AND b.Transaction_DATE = @Ad_Transaction_DATE) f) up UNPIVOT (Element_VALUE FOR Element_NAME IN (TO_IVDOutOfStateCase_ID, TO_Fips_CODE)) AS pvt);

           INSERT INTO #NoticeElementsData_P1
                       (Element_NAME,
                        Element_Value)
           (SELECT Element_NAME,
                   Element_VALUE
              FROM(SELECT CONVERT(VARCHAR(100), Petitioner_NAME) Petitioner_NAME,
                          CONVERT(VARCHAR(100), PETITIONER_SSN) PetitionerSsn_NUMB
                     FROM (SELECT TOP 1 ISNULL(a.First_NAME, '') + ' ' + ISNULL(a.Middle_NAME, '') + ' ' + ISNULL(a.Last_NAME, '') AS Petitioner_NAME,
                                        a.MemberSsn_NUMB AS PETITIONER_SSN
                             FROM CPTB_Y1 a
                            WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO
                              AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                              AND a.Transaction_DATE = @Ad_Transaction_DATE
                              AND a.Relationship_CODE = @Lc_RelationshipCaseCp_TEXT) f) up UNPIVOT (Element_VALUE FOR Element_NAME IN (Petitioner_NAME, PetitionerSsn_NUMB)) AS pvt);

           INSERT INTO #NoticeElementsData_P1
                       (Element_NAME,
                        Element_Value)
           (SELECT pvt.Element_NAME,
                   pvt.Element_VALUE
              FROM(SELECT CONVERT(VARCHAR(100), Respondent_NAME) Respondent_NAME,
                          CONVERT(VARCHAR(100), RESPONDENT_SSN) RespondentSsn_NUMB
                     FROM (SELECT TOP 1 ISNULL(a.First_NAME, '') + ' ' + ISNULL(a.Middle_NAME, '') + ' ' + ISNULL(a.Last_NAME, '') AS Respondent_NAME,
                                        a.MemberSsn_NUMB AS RESPONDENT_SSN
                             FROM CNCB_Y1 a
                            WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO
                              AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                              AND a.Transaction_DATE = @Ad_Transaction_DATE) f) up UNPIVOT (Element_VALUE FOR Element_NAME IN (Respondent_NAME, RespondentSsn_NUMB)) AS pvt);
          END
         
         EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS
          @Ac_StateFips_CODE        = @Ac_Recipient_ID,
          @Ac_TypeAddress_CODE      = @Lc_TypeAddressSta_CODE,
          @Ac_SubTypeAddress_CODE   = @Lc_SubTypeAddress_CODE,
          @As_Prefix_TEXT           = 'TO_AGENCY_SDU',
          @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
          @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

         IF @Ac_Msg_CODE = @Lc_StatusFailed_CODE
          BEGIN
           RAISERROR (50001,16,1);
          END
        END
      END
    END

   SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;

   DECLARE @Li_Error_NUMB     INT,
           @Li_ErrorLine_NUMB INT;

   SET @Li_Error_NUMB = ERROR_NUMBER ();
   SET @Li_ErrorLine_NUMB = ERROR_LINE ();

   IF (@Li_Error_NUMB <> 50001)
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_SqlData_TEXT,
    @An_Error_NUMB            = @Li_Error_NUMB,
    @An_ErrorLine_NUMB        = @Li_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
