/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_SELECT_INITIATING_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICES$SP_SELECT_INITIATING_DTLS
Programmer Name	:	IMP Team.
Description		:	This procedure is to fetch the initiatinig details
Frequency		:	
Developed On	:	2/17/2012
Called By		:	
Called On		:	BATCH_GEN_NOTICES$SP_FORMAT_BUILD_XML
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_SELECT_INITIATING_DTLS] (
                    @Ac_IVDOutOfStateFips_CODE          CHAR (2),
					@Ad_Transaction_DATE                DATE,
					@Ad_Run_DATE						DATE,
					@An_TransHeader_IDNO                NUMERIC (12),
					@Ac_InitiatingFips_ID             CHAR (7),
					@Ac_Recipient_CODE                  CHAR (2),
					@Ac_TypeAddress_CODE                CHAR (1),
					@Ac_Worker_ID                       CHAR (30),
					@Ac_Notice_ID                       CHAR (8),
					@An_Case_IDNO                       NUMERIC (6),
					@An_MemberMci_IDNO					NUMERIC(10),
					@Ac_File_ID                         CHAR (15),
					@Ac_Recipient_ID                    VARCHAR (10),
					@Ac_TransOtherState_INDC            CHAR (1),
					@Ac_Msg_CODE                        CHAR (5) OUTPUT,
					@As_DescriptionError_TEXT           VARCHAR (4000) OUTPUT
 )
AS
 BEGIN
 SET NOCOUNT ON;
  DECLARE @Lc_Space_TEXT              CHAR(1) = ' ',
          @Lc_Dot_TEXT                CHAR(1) = '.',
          @Lc_RespondInit_CODE        CHAR(1) = '',
          @Lc_StatusFailed_CODE       CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE      CHAR(1) = 'S',
          @Lc_StatusOpen_CODE		  CHAR(1) = 'O',
          @Lc_RelationshipCaseCp_TEXT CHAR(1) = 'C',
          @Lc_TransOtherStateI1_INDC  CHAR(1) = 'I',
          @Lc_RespondInitR_CODE	      CHAR(1) = 'R',
          @Lc_RespondInitS_CODE	      CHAR(1) = 'S',
          @Lc_RespondInitY_CODE	      CHAR(1) = 'Y',
          @Lc_RecdetOtherState_CODE   CHAR(2) = 'OS',
          @Lc_InStateFips_CODE        CHAR(2) = '10',
          @Lc_SubTypeAddress_CODE     CHAR(3) = 'SDU',
          @Lc_TypeAddressSta_CODE     CHAR(3) = 'STA',
          @Lc_SubTypeAddressCrg_CODE  CHAR(3) = 'CRG',
          @Lc_NoticeInt14_IDNO        CHAR(8) = 'INT-14',
          @Lc_OthpStateFips_CODE	  VARCHAR(50) = 'OthpStateFips_CODE',
          @Ls_Procedure_NAME          VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_SELECT_INITIATING_DTLS',
          @Ld_High_DATE               DATE = '12/31/9999';
  DECLARE 
          @Ln_SsnPetitionerNumber_NUMB NUMERIC(11),
          @Ln_SsnRespondentNumber_NUMB NUMERIC(11),
          @Lc_ToAgencyFips_IDNO        CHAR(7),
          @Lc_AssignedFips_CODE		   CHAR(7),	
          @Lc_IVDOutOfStateCase_ID     CHAR(15),
          @Lc_InitiatingCase_ID        CHAR(15),
          @Lc_First_NAME               CHAR(16),
          @Lc_IVDOutOfStateFile_ID     CHAR(17),
          @Lc_InitiatingFile_ID        CHAR(17),
          @Lc_Last_NAME                CHAR(20),
          @Lc_Middle_NAME              CHAR(20),
          @Lc_Case_Worker_ID           CHAR(30),
          @Lc_County_NAME              CHAR(40),
          @Ls_Petitioner_NAME          VARCHAR(65),
          @Ls_Respondent_NAME          VARCHAR(65),
          @Ls_Sql_TEXT                 VARCHAR(200),
          @Ls_Sqldata_TEXT             VARCHAR(400),
          @Ls_DescriptionError_TEXT    VARCHAR(4000);

  /* @An_MemberMci_IDNO expects RespondentMci_IDNO value */
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ac_TransOtherState_INDC = ISNULL (@Ac_TransOtherState_INDC, 'O');
   SET @Lc_County_NAME = NULL;
	
   --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - Start
   SELECT @Lc_AssignedFips_CODE = c.AssignedFips_CODE 
	   FROM CASE_Y1 c
	   WHERE c.Case_IDNO = @An_Case_IDNO
	   AND c.StatusCase_CODE = @Lc_StatusOpen_CODE;
   --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - End

	-- 13043 - CR0336 INT-14 UIFSA Acknowledgement Data Mapping Changes 20131204 Fix - Start
	SELECT @Lc_RespondInit_CODE = C.RespondInit_CODE 
				FROM CASE_Y1 C WHERE 
				C.Case_IDNO = @An_Case_IDNO
				
   INSERT INTO #NoticeElementsData_P1
                  (Element_NAME,
                   element_value)
           VALUES ('intergovermental_indc',
                   @Lc_RespondInit_CODE);
		
		--13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - START                   
		/*
         FROM_AGENCY_SDU_Fips_NAME ,
         FROM_AGENCY_SDU_LINE1_ADDR ,
         FROM_AGENCY_SDU_LINE2_ADDR ,
         FROM_AGENCY_SDU_CITY_ADDR ,
         FROM_AGENCY_SDU_STATE_ADDR ,
         FROM_AGENCY_SDU_Zip_ADDR ,
         FROM_AGENCY_SDU_COUNTRY_ADDR ,
         FROM_AGENCY_SDU_PHONE_NUMB ,
         FROM_AGENCY_SDU_FAX_NUMB ,
         FROM_AGENCY_SDU_FIPS_CODE
        */
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6)) + ', Worker_ID = ' + ISNULL(@Ac_Worker_ID, '');

        
        IF (@Lc_RespondInit_CODE IN(@Lc_RespondInitR_CODE,@Lc_RespondInitS_CODE,@Lc_RespondInitY_CODE))
        BEGIN
			SELECT @Lc_InStateFips_CODE = Element_VALUE 
				FROM #NoticeElementsData_P1 
				WHERE Element_NAME=@Lc_OthpStateFips_CODE 
        END
		

        EXECUTE BATCH_GEN_NOTICE_CNET$SP_GET_SDU_ADDR_DTLS
         @Ac_StateFips_CODE        = @Lc_InStateFips_CODE,
         @Ac_TypeAddress_CODE      = @Lc_TypeAddressSta_CODE,
         @Ac_SubTypeAddress_CODE   = @Lc_SubTypeAddress_CODE,
         @As_Prefix_TEXT           = 'FROM_AGENCY_SDU',
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

        IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
         BEGIN
          RAISERROR (50001,16,1);
         END                   
    --13738 - CR0440 INT-02 UIFSA Transmittal 2 Changes Requested by Workers 20141120 - Fix - END
                   
	-- 13043 - CR0336 INT-14 UIFSA Acknowledgement Data Mapping Changes 20131204 Fix - End
   IF @Ac_Recipient_CODE = @Lc_RecdetOtherState_CODE
   -- FOR Outgoing Transaction 
   BEGIN
    IF @Ac_TransOtherState_INDC <> @Lc_TransOtherStateI1_INDC
     BEGIN
      SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS';
      SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6));
     
      EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_DE_FIPS
       @An_Case_IDNO             = @An_Case_IDNO,
       @As_Prefix_TEXT           = 'FROM_FIPS_CODE',--'FROM_AGENCY_SDU_FIPS_CODE',
       @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
       @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

      IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
       BEGIN
        RAISERROR (50001,16,1);
       END

      SET @Lc_InitiatingCase_ID = CAST(@An_Case_IDNO AS VARCHAR);

      INSERT INTO #NoticeElementsData_P1
                  (Element_NAME,
                   element_value)
           VALUES ('FROM_IVDOutOfStateCase_ID',
                   @Lc_InitiatingCase_ID);

      SET @Lc_InitiatingFile_ID = @Ac_File_ID;

      INSERT INTO #NoticeElementsData_P1
                  (Element_NAME,
                   element_value)
           VALUES ('FROM_File_ID',
                   @Lc_InitiatingFile_ID);

      IF @Ac_Notice_ID <> @Lc_NoticeInt14_IDNO
       BEGIN
        IF @Ac_Worker_ID = 'BATCH'
         BEGIN
          SET @Lc_Case_Worker_ID = dbo.BATCH_FIN_REPORTS$SF_GET_CASE_WORKER (@An_Case_IDNO);
         END
        ELSE
         BEGIN
          SET @Lc_Case_Worker_ID = @Ac_Worker_ID;
         END

   
        /*
        Below tags will come from the BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS procedure
        worker_last_name, worker_first_name, worker_middle_name, 
                            worker_title_code, worker_descvalue_text, worker_contact_eml,
                             worker_full_display_name, worker_sso_id, esign_login_worker_text,
                             WorkerTitle_text
        */
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6)) + ', Case_Worker_ID = ' + ISNULL(@Lc_Case_Worker_ID, '');
       
        EXECUTE BATCH_GEN_NOTICE_WORKER$SP_GET_WORKER_DTLS
         @Ac_Worker_ID             = @Lc_Case_Worker_ID,
         @As_Prefix_TEXT           = 'CASE',
         @Ad_Run_DATE              = @Ad_Run_DATE,
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

        IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
         BEGIN
          RAISERROR (50001,16,1);
         END

        INSERT INTO #NoticeElementsData_P1
                    (Element_NAME,
                     Element_VALUE)
        SELECT Element_NAME,
               Element_VALUE
          FROM (SELECT CONVERT (VARCHAR (100), a.from_agency_contact_name) AS from_agency_contact_name
                  FROM (SELECT RTRIM(e.First_NAME) + ' ' + RTRIM(e.Middle_NAME) + ' ' + RTRIM(e.Last_NAME) AS from_agency_contact_name
                          FROM USEM_Y1 e
                         WHERE e.Worker_ID = @Lc_Case_Worker_ID
                           AND e.EndValidity_DATE =  @Ld_High_DATE
                           AND @Ad_Run_DATE BETWEEN e.BeginEmployment_DATE AND e.EndEmployment_DATE) a) up UNPIVOT (Element_VALUE FOR Element_NAME IN (from_agency_contact_name)) AS pvt;

      
        /*
        Below tags needs from the below procedures BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS &
        BATCH_GEN_NOTICE_WORKER$SP_GET_LOGIN_WORKER_OFIC_DTLS
        
        FROM_AGENCY_NAME,
        FROM_AGENCY_ATTN_ADDR ,
        FROM_AGENCY_LINE1_ADDR ,
        FROM_AGENCY_LINE2_ADDR ,
        FROM_AGENCY_CITY_ADDR ,
        FROM_AGENCY_STATE_ADDR ,
        FROM_AGENCY_ZIP_ADDR ,
        FROM_AGENCY_COUNTRY_ADDR ,
        FROM_AGENCY_PHONE_NUMB ,
        FROM_AGENCY_FAX_NUMB ,
        
        */
        IF @Ac_Worker_ID = 'BATCH'
         BEGIN
          SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS';
          SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6));
         
          EXECUTE BATCH_GEN_NOTICE_CM$SP_GET_CASE_WORKER_OFIC_DTLS
           @An_Case_IDNO             = @An_Case_IDNO,
           @Ad_Run_DATE              = @Ad_Run_DATE,
           @As_Prefix_TEXT           = 'FROM_AGENCY',
           @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
           @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

          IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
        ELSE
         BEGIN
         --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - Start
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' +  ISNULL( CAST(@An_Case_IDNO AS VARCHAR(6)),'') + ', Fips_CODE = ' + ISNULL(CAST(@Lc_AssignedFips_CODE AS VARCHAR),'');
         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
         
         EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
         @Ac_Fips_CODE             = @Lc_AssignedFips_CODE,
         @As_Prefix_TEXT           = 'FROM_AGENCY',
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
         
         IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
           BEGIN
            RAISERROR (50001,16,1);
           END
         END
		 --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - End
        
       
       END
      ELSE 
       BEGIN
        SET @Lc_First_NAME = NULL;
        SET @Lc_Last_NAME = NULL;
        SET @Lc_Middle_NAME = NULL;
        /*
         FROM_AGENCY_Fips_NAME ,
         FROM_AGENCY_LINE1_ADDR ,
         FROM_AGENCY_LINE2_ADDR ,
         FROM_AGENCY_CITY_ADDR ,
         FROM_AGENCY_STATE_ADDR ,
         FROM_AGENCY_Zip_ADDR ,
         FROM_AGENCY_COUNTRY_ADDR ,
         FROM_AGENCY_PHONE_NUMB ,
         FROM_AGENCY_FAX_NUMB ,
         FROM_AGENCY_FIPS_CODE
        */

         --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - Start
         SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' +  ISNULL( CAST(@An_Case_IDNO AS VARCHAR(6)),'') + ', Fips_CODE = ' + ISNULL(CAST(@Lc_AssignedFips_CODE AS VARCHAR),'');
         SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
         
         EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
         @Ac_Fips_CODE             = @Lc_AssignedFips_CODE,
         @As_Prefix_TEXT           = 'FROM_AGENCY',
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
         
         IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
         BEGIN
          RAISERROR (50001,16,1);
         END
		 --13585 - INT-02 -UIFSA Transmittal 2 - Defect found by users	Fix - End
       END
     END
    ELSE /* FOR Incoming Transaction */
     BEGIN
      IF (@An_Case_IDNO IS NOT NULL
          AND @An_Case_IDNO != 0)
          AND (@An_TransHeader_IDNO IS NULL 
				OR @An_TransHeader_IDNO = 0)
       BEGIN
        DECLARE @Lc_Temp_TEXT CHAR (2);

        SET @Lc_Temp_TEXT = SUBSTRING (CAST (@Ac_InitiatingFips_ID AS CHAR), 1, 2);
        /*
        CaretakerOption_TEXT
        Petitioner_NAME, 
        FostercareOption_TEXT, 
        Respondent_NAME, 
        PetitionerSsn_NUMB, 
        RespondentSsn_NUMB
        FROM_IVDOutOfStateCase_ID,
        FROM_Fips_CODE,
        FROM_File_ID
        */
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6)) + ', NcpMemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10));
        
        EXECUTE BATCH_GEN_NOTICE_CNET$SP_SELECT_OTHER_STATE_DTLS
         @Ac_IVDOutOfStateFips_CODE = @Lc_Temp_TEXT,
         @As_Prefix_TEXT            = 'FROM',
         @An_Case_IDNO              = @An_Case_IDNO,
         @An_MemberMci_IDNO         = @An_MemberMci_IDNO,
         @Ad_Run_DATE               = @Ad_Run_DATE,
         @Ac_Msg_CODE               = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT  = @As_DescriptionError_TEXT OUTPUT;

        IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
         BEGIN
          RAISERROR (50001,16,1);
         END
       END
      ELSE
       BEGIN
        /* selecting the Other state information from CSNET table if the CSNET transaction
                    not assigned the Delaware Case ID.*/
        SET @Ls_Sql_TEXT = 'SELECT CTHB_Y1';
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6)) + ', NcpMemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', TransHeader_IDNO = ' + CAST(@An_TransHeader_IDNO AS VARCHAR) + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + CAST(@Ad_Transaction_DATE AS VARCHAR(10));
        
        SELECT @Lc_IVDOutOfStateCase_ID = b.IVDOutOfStateCase_ID,
               @Lc_ToAgencyFips_IDNO = ISNULL (b.IVDOutOfStateFips_CODE, '') + ISNULL (b.IVDOutOfStateCountyFips_CODE, '') + ISNULL (b.IVDOutOfStateOfficeFips_CODE, '')
          FROM CTHB_Y1  b
         WHERE b.TransHeader_IDNO = @An_TransHeader_IDNO
           AND b.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
           AND b.Transaction_DATE = @Ad_Transaction_DATE;

        /*
        ps_id_case_oth_state		FROM_ID_CASE_INITIATE		FROM_IVDOutOfStateCase_ID
        ps_to_agency_id_fips		FROM_INITIATE_ID_FIPS		FROM_AGENCY_SDU_FIPS_CODE
        ps_id_docket_oth_state		FROM_ID_DOCKET_INITIATE		FROM_File_ID
        ps_name_petitioner,
        ps_ssn_petitioner_number
        ps_name_petitioner,
        ps_ssn_petitioner_number
        */
        SET @Ls_Sql_TEXT = 'SELECT CSDB_Y1';

        SELECT @Lc_IVDOutOfStateFile_ID = RespondingFile_ID
          FROM CSDB_Y1 c
         WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO
           AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
           AND c.Transaction_DATE = @Ad_Transaction_DATE;

        INSERT INTO #NoticeElementsData_P1(
                           Element_NAME,
                           Element_VALUE)
             VALUES ('FROM_IVDOutOfStateCase_ID',
                     ISNULL(@Lc_IVDOutOfStateCase_ID, ''));

        INSERT INTO #NoticeElementsData_P1(
                           Element_NAME,
                           Element_VALUE)
             VALUES ('FROM_FIPS_CODE',
                     ISNULL(@Lc_ToAgencyFips_IDNO, ''));

        INSERT INTO #NoticeElementsData_P1(
                           Element_NAME,
                           Element_VALUE)
             VALUES ('FROM_File_ID',
                     ISNULL(@Lc_IVDOutOfStateFile_ID, ''));

        SET @Ls_Sql_TEXT = 'SELECT CPTB_Y1';

        
       END

      SET @Lc_InitiatingCase_ID = @Lc_IVDOutOfStateCase_ID;
      SET @Lc_InitiatingFile_ID = @Lc_IVDOutOfStateFile_ID;

      IF (@An_Case_IDNO IS NOT NULL
          AND @An_Case_IDNO != 0)
       BEGIN
        SET @Ls_Sqldata_TEXT = '  Case_IDNO = ' + ISNULL (@Lc_InitiatingCase_ID, '') + ', IVDOutOfStateFips_CODE = ' + ISNULL (SUBSTRING (CAST (@Ac_InitiatingFips_ID AS VARCHAR), 1, 2), '');
        SET @Ls_Sql_TEXT = 'SELECT ICAS_Y1 ';

        --FROM_AGENCY_CONTACT_NAME
        INSERT INTO #NoticeElementsData_P1
                    (Element_NAME,
                     Element_Value)
        SELECT 'FROM_AGENCY_CONTACT_NAME' AS Element_NAME,
               FROM_AGENCY_CONTACT_NAME AS Element_VALUE
          FROM (SELECT TOP 1 ISNULL (c.ContactFirst_NAME, '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (CASE
                                                                                                       WHEN c.ContactMiddle_NAME IS NOT NULL
                                                                                                        THEN ISNULL (SUBSTRING (c.ContactMiddle_NAME, 1, 1), '') + ISNULL (@Lc_Dot_TEXT, '') + ISNULL (@Lc_Space_TEXT, '')
                                                                                                      END, '') + ISNULL (c.ContactLast_NAME, '') AS FROM_AGENCY_CONTACT_NAME
                  FROM ICAS_Y1 c
                 WHERE c.IVDOutOfStateCase_ID = @Lc_InitiatingCase_ID
				   AND c.Status_CODE = @Lc_StatusOpen_CODE
                   AND c.IVDOutOfStateFips_CODE = SUBSTRING (CAST (@Ac_InitiatingFips_ID AS VARCHAR), 1, 2)
                   AND c.EndValidity_DATE = @Ld_High_DATE) f;
       END
      ELSE--IF (@An_Case_IDNO IS NULL OR ZERO)
       BEGIN
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + CAST (ISNULL (@An_Case_IDNO, 0) AS VARCHAR(6)) + ', NcpMemberMci_IDNO = ' + CAST(@An_MemberMci_IDNO AS VARCHAR(10)) + ', InitiatingCase_IDNO = ' + CAST(@Lc_InitiatingCase_ID AS VARCHAR) + ', IVDOutOfStateFips_CODE = ' + ISNULL(@Ac_IVDOutOfStateFips_CODE, '') + ', Transaction_DATE = ' + CAST(@Ad_Transaction_DATE AS VARCHAR(10));
        SET @Ls_Sql_TEXT = 'SELECT CSDB_Y1 ';

        INSERT INTO #NoticeElementsData_P1
                    (Element_NAME,
                     Element_Value)
        (SELECT Element_NAME,
                Element_VALUE
           FROM (SELECT CONVERT (VARCHAR (100), FROM_AGENCY_CONTACT_NAME) FROM_AGENCY_CONTACT_NAME
                   FROM (SELECT TOP 1 ISNULL (c.First_NAME, '') + ISNULL (@Lc_Space_TEXT, '') + ISNULL (CASE
                                                                                                         WHEN c.Middle_NAME IS NOT NULL
                                                                                                          THEN ISNULL (SUBSTRING (c.Middle_NAME, 1, 1), '') + ISNULL (@Lc_Dot_TEXT, '') + ISNULL (@Lc_Space_TEXT, '')
                                                                                                        END, '') + ISNULL (c.Last_NAME, '') AS FROM_AGENCY_CONTACT_NAME
                           FROM CSDB_Y1 c
                          WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO--@Ln_InitiatingCase_IDNO
                            AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
                            AND c.Transaction_DATE = @Ad_Transaction_DATE) f) up UNPIVOT (Element_VALUE FOR Element_NAME IN (FROM_AGENCY_CONTACT_NAME)) AS pvt);
       END

      IF (@Ac_InitiatingFips_ID IS NOT NULL
          AND @Ac_InitiatingFips_ID != '')
       BEGIN /*
             						FROM_AGENCY_NAME,
             						FROM_AGENCY_Fips_CODE, 
             						FROM_AGENCY_Line1_ADDR,
             						FROM_AGENCY_Line2_ADDR,     
             						FROM_AGENCY_City_ADDR,
             						FROM_AGENCY_State_ADDR,
             						FROM_AGENCY_Zip_ADDR,
             						FROM_AGENCY_Country_ADDR,
             						FROM_AGENCY_Phone_NUMB,    
             						FROM_AGENCY_Fax_NUMB
             						*/
        SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' +  ISNULL( CAST(@An_Case_IDNO AS VARCHAR(6)),'') + ', InitiatingCase_IDNO = ' + ISNULL(CAST(@Ac_InitiatingFips_ID AS VARCHAR),'');
        SET @Ls_Sql_TEXT = 'EXECUTE BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS';
        EXEC BATCH_GEN_NOTICE_MEMBER$SP_GET_FIPS_DETAILS
         @Ac_Fips_CODE             = @Ac_InitiatingFips_ID,
         @As_Prefix_TEXT           = 'FROM_AGENCY',
         @Ac_Msg_CODE              = @Ac_Msg_CODE OUTPUT,
         @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;

        IF (@Ac_Msg_CODE = @Lc_StatusFailed_CODE)
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
