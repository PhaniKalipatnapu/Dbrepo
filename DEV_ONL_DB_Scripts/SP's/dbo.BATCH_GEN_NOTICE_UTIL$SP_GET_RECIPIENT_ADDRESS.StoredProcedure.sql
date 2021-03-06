/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


   /*
   --------------------------------------------------------------------------------------------------------------------
   Program Name      :BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS
   Programmer Name   : IMP Team.
   Description       : The procedure BATCH_GEN_UITL$SP_GET_RECIPIENT_ADDRESS gets Notice Recipeint addresses
   Frequency         :
   Developed On      : 4/20/2011
   Called BY         :
   Called On         :
   ------------------------------------------------------------------------------------------------------------------
   Modified BY       :
   Modified On       :
   Version No        : 1.0
   --------------------------------------------------------------------------------------------------------------------
   */
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS] (
   @Ac_Notice_ID                      CHAR (8),
   @An_Case_IDNO					  NUMERIC(6) = 0,
   @Ac_Recipient_ID                   VARCHAR (10),
   @Ac_Recipient_CODE                 VARCHAR (4),
   @Ad_Run_DATE						  DATE,
   @Ac_Msg_CODE                       VARCHAR (5) OUTPUT,
   @As_DescriptionError_TEXT          VARCHAR (4000) OUTPUT)
AS
   BEGIN
      CREATE TABLE #MemberAddressDetails_P1
      (
         Line1_ADDR         VARCHAR (50),
         Line2_ADDR         VARCHAR (50),
         State_ADDR         VARCHAR (2),
         City_ADDR          VARCHAR (28),
         Zip_ADDR           VARCHAR (15),
         TypeAddress_CODE   VARCHAR,
         Status_CODE        CHAR,
         Ind_ADDR           VARCHAR
      )

      DECLARE
         @Lc_Cerification_Status_Good CHAR (1) = 'Y',
         @Lc_verification_status_Pending CHAR (1) = 'P',
         @Lc_StatusSuccess_CODE CHAR(1) = 'S',
         @Lc_StatusFailed_CODE  CHAR(1) = 'F',
         @Lc_TypeAddrZ_CODE	    CHAR(1) = 'Z',
		 @Lc_TypeAddrV_CODE	    CHAR(1) = 'V',
		 @Lc_NoticeEnf01_ID	    CHAR(8)	= 'ENF-01',
		 @Lc_NoticeEnf03_ID     CHAR(8)	= 'ENF-03',
		 @Lc_RecipientSi_CODE   CHAR(2)	= 'SI',	
		 @Lc_RecipientOe_CODE   CHAR(2)	= 'OE',
         @Ls_Procedure_NAME VARCHAR (100) = 'BATCH_GEN_NOTICE_UTIL$SP_GET_RECIPIENT_ADDRESS',
         @Ld_High_Date DATE = '12/31/9999';

      DECLARE
         @Lc_MailRecipient_CODE CHAR (1) = '',
         /*
            1- Member ID
            2- FIPS CODE
            3 - OTHP ID
         */
         @Lc_AddressHierarchy_CODE CHAR(1) = '',
         @Lc_Notice_ID_LOC_01 CHAR(8)='',
         @Ls_Line1_ADDR VARCHAR (50),
         @Ls_Line2_ADDR VARCHAR (50),
         @Ls_State_ADDR VARCHAR (2),
         @Ls_Zip_ADDR VARCHAR (15),
         @Ls_City_ADDR VARCHAR (28),
         @Lc_Status_CODE CHAR,
         @Ln_Recipient_IDNO NUMERIC (10),
         @Lc_TypeAddress_CODE VARCHAR,
         @Lc_Addr_INDC CHAR,
         @Lc_TypeAddress_State_CODE VARCHAR (3),
         @Lc_TypeAddress_Trb_CODE VARCHAR (3),
         @Lc_Sub_TypeAddress_Crg_CODE VARCHAR (3),
         @Lc_Sub_TypeAddress_T01_CODE VARCHAR (3),
         @Ls_IVDOutOfStateOfficeFips_00_CODE VARCHAR (2),
         @Lc_TypeAddress_locate_CODE VARCHAR (3),
         @Lc_Sub_TypeAddress_c01_CODE VARCHAR (3),
         @Ls_IVDOutOfStateCountyFips_CODE VARCHAR (3),
         @Ls_IVDOutOfStateFips_us_max_CODE VARCHAR (2),
         @Ls_IVDOutOfStateFips_Tribal_CODE VARCHAR (2),
         @Lc_TypeAddress_Int_CODE VARCHAR (3),
         @Lc_Sub_TypeAddress_Int_CODE VARCHAR (3),
         @GetAddress_CUR CURSOR,
         @Ls_Sql_TEXT VARCHAR (100) = '',
         @Ls_Sqldata_TEXT VARCHAR (1000) = '',
         @Ls_DescriptionError_TEXT VARCHAR (4000);


	  SET @Lc_Notice_ID_LOC_01 = 'LOC-01';
      --Address Type
      SET @Lc_TypeAddress_State_CODE = 'STA';

      --Indicates code sub type address
      SET @Lc_Sub_TypeAddress_Crg_CODE = 'CRG';

      -- Indicates the Interstate Case office
      SET @Ls_IVDOutOfStateOfficeFips_00_CODE = '00';

      SET @Lc_TypeAddress_locate_CODE = 'LOC';
      --Indicates code sub type address
      SET @Lc_Sub_TypeAddress_c01_CODE = 'C01';
      
      -- Tribal Type code and sub Type address
      SET @Lc_TypeAddress_Trb_CODE = 'TRB';
      
      SET @Lc_Sub_TypeAddress_T01_CODE = 'T01';

      -- Indicates the Interstate Case County
      SET @Ls_IVDOutOfStateCountyFips_CODE = '000';

      SET @Ls_IVDOutOfStateFips_us_max_CODE = '99';
      
      SET @Ls_IVDOutOfStateFips_Tribal_CODE = '90';
      --International FIPS
      SET @Lc_TypeAddress_Int_CODE = 'INT';

      SET @Lc_Sub_TypeAddress_Int_CODE = 'FRC';


      SET @Lc_verification_status_pending = 'P';

	  SET @Lc_StatusFailed_CODE = 'F';

      SET @Lc_StatusSuccess_CODE = 'S';

      BEGIN TRY
		 
         SELECT @Lc_MailRecipient_CODE =
                   CASE
                      WHEN @Ac_Recipient_CODE IN
                              ('DG',
                               'FC',
                               'FI',
                               'FS',
                               'HA',
                               'JL',
                               'LA',
                               'IC',
                               'NA',
                               'OE',
                               'OT',
                               'PA',
                               'PU',
                               'SI',
                               'SS',
                               'WR',
							   'FR_3')
                      THEN
                         '3'
                      WHEN @Ac_Recipient_CODE IN
                              ('FR_1', 'GR', 'MC', 'MN', 'MS', 'NO', 'NP', 'OP', 'PM')
                      THEN
                         '1'
                      WHEN @Ac_Recipient_CODE IN ('FR_2', 'OS')
                      THEN
                         '2'
                   END;

         IF (@Lc_MailRecipient_CODE IN ('1', '3'))
            BEGIN
               SET @Ln_Recipient_IDNO = CAST (@Ac_Recipient_ID AS NUMERIC (10));
            END

         IF (@Lc_MailRecipient_CODE = '1')
            BEGIN
				SELECT @Lc_AddressHierarchy_CODE = AddressHierarchy_CODE
				  FROM NREF_Y1
				 WHERE Notice_ID =@Ac_Notice_ID
				   AND EndValidity_DATE = @Ld_High_DATE;
            
               IF @Lc_AddressHierarchy_CODE = '1' 
                  BEGIN
                     SET @GetAddress_CUR =
                            CURSOR FOR
                               SELECT Line1_ADDR,
                                      Line2_ADDR,                              
                                      State_ADDR,
                                      Zip_ADDR,
                                      City_ADDR,
                                      Status_CODE,
                                      TypeAddress_CODE,
                                      1 AS Ind_ADDR
                                 FROM 
									  (SELECT ROW_NUMBER ()
											  OVER (
												 
												 ORDER BY
													Status_CODE DESC,
													TransactionEventSeq_NUMB DESC,
													Update_DTTM DESC) rnm,
											  a.*
										 FROM (SELECT a.*
												 FROM AHIS_Y1 a
												WHERE a.MemberMci_IDNO = CAST (@Ac_Recipient_ID AS NUMERIC) 
													  AND TypeAddress_CODE = 'M'
													  AND ( (    @Ad_Run_DATE BETWEEN a.Begin_DATE
                                                                                  AND a.End_DATE
															 AND Status_CODE = 'Y')
														   
														  )) AS a
									  ) AS a
								WHERE a.rnm = 1
                  END
               -- Confirmed Good Court Address for NCP and Confirmed Good Mailing Address For CP
               ELSE IF @Lc_AddressHierarchy_CODE = '2' 
                     BEGIN
                        SET @GetAddress_CUR =
                               CURSOR FOR
                                  SELECT Line1_ADDR,
                                         Line2_ADDR,                              
                                         State_ADDR,
                                         Zip_ADDR,
                                         City_ADDR,
                                         Status_CODE,
                                         TypeAddress_CODE,
                                         (CASE WHEN a.addr_rnm = 1 THEN 1 ELSE 0 END) Ind_ADDR	
										
									FROM
										  (SELECT ROW_NUMBER() OVER(PARTITION BY a.MemberMci_IDNO ORDER BY addr_hrchy, Status_CODE DESC,
																										TransactionEventSeq_NUMB DESC, Update_DTTM DESC) addr_rnm,
												 a.*
											FROM (SELECT                          
														a.*,
														 CASE
															WHEN c.CaseRelationship_CODE IN ('A', 'P')
																 AND a.TypeAddress_CODE = 'C'
															THEN
															   1
															WHEN c.CaseRelationship_CODE IN ('A', 'P')
																 AND a.TypeAddress_CODE = 'M'
															THEN
															   2
															WHEN c.CaseRelationship_CODE = 'C'
																 AND a.TypeAddress_CODE = 'M'
															THEN
															   1
														 END
															addr_hrchy
													FROM CMEM_Y1 c,
														 (SELECT ROW_NUMBER ()
																 OVER (
																	PARTITION BY a.MemberMci_IDNO,
																				 TypeAddress_CODE
																	ORDER BY
																	   Status_CODE DESC,
																	   TransactionEventSeq_NUMB DESC,
																	   Update_DTTM DESC)
																	rnm,
																 a.*
															FROM (SELECT a.*
																	FROM AHIS_Y1 a
																   WHERE a.MemberMci_IDNO =
																			CAST (
																			   @Ac_Recipient_ID AS NUMERIC) 
																		 AND TypeAddress_CODE IN ('M', 'C')
																		 AND ( (	@Ad_Run_DATE BETWEEN a.Begin_DATE
																									 AND a.End_DATE
																				AND Status_CODE = 'Y')
																			 
																			  )) AS a) AS a
												   WHERE c.Case_IDNO = @An_Case_IDNO   
														 AND a.MemberMci_IDNO = c.MemberMci_IDNO
														 AND c.CaseMemberStatus_CODE = 'A'
														 AND c.CaseRelationship_CODE IN ('A', 'P', 'C')) AS a
														 WHERE ISNULL(addr_hrchy,0) <> 0
										  ) AS a
                           
                     END
                  -- Last Known Court Address and Confirmed Good Mailing Address if Different from Last Known Court Address
                  ELSE IF @Lc_AddressHierarchy_CODE = '3' 
                        BEGIN
                           SET @GetAddress_CUR =
                                  CURSOR FOR
                                     SELECT Line1_ADDR,
                                            Line2_ADDR,                              
                                            State_ADDR,
                                            Zip_ADDR,
                                            City_ADDR,
                                            Status_CODE,
                                            TypeAddress_CODE,
                                            (CASE WHEN a.addr_hrchy = 1 THEN 1 ELSE 0 END) Ind_ADDR--,
                                            
                                       FROM (SELECT (CASE
                                                                WHEN TypeAddress_CODE = 'M'
                                                                THEN
                                                                   1
                                                                 WHEN TypeAddress_CODE = 'C'
                                                                THEN
                                                                   1
                                                                ELSE
                                                                   2
                                                             END)
                                                               addr_hrchy,
                                                            a.*
                                                       FROM (SELECT ROW_NUMBER ()
                                                                    OVER (
                                                                       PARTITION BY a.MemberMci_IDNO
                                                                       ORDER BY   rnm   
																		  )
                                                                       ronm,
                                                                    a.*
                                                               FROM (SELECT ROW_NUMBER ()
                                                                            OVER (
                                                                               PARTITION BY a.MemberMci_IDNO,
                                                                                            TypeAddress_CODE
                                                                               ORDER BY
                                                                                  Status_CODE DESC,
                                                                                  TransactionEventSeq_NUMB DESC,
                                                                                  Update_DTTM DESC)
                                                                               rnm,
                                                                            a.*
                                                                       FROM (SELECT a.*
                                                                               FROM AHIS_Y1 a
                                                                              WHERE a.MemberMci_IDNO =
                                                                                       CAST (
                                                                                          @Ac_Recipient_ID AS NUMERIC) 
                                                                                    AND TypeAddress_CODE IN
                                                                                           ('C')
                                                                                    AND ( (	   @Ad_Run_DATE BETWEEN a.Begin_DATE
																												AND a.End_DATE
                                                                                           AND Status_CODE IN
                                                                                                  ('Y') 
                                                                                                       )
                                                                                         
                                                                                         )) AS a) a
                                                              WHERE rnm = 1
                                                             UNION
                                                             SELECT 1 AS ronm, 1 AS rnm, m.*
                                                               FROM (SELECT a.*
                                                                       FROM AHIS_Y1 a
                                                                      WHERE a.MemberMci_IDNO =
                                                                               CAST (
                                                                                  @Ac_Recipient_ID AS NUMERIC) 
                                                                            AND TypeAddress_CODE =
                                                                                   'M'
                                                                            AND @Ad_Run_DATE BETWEEN a.Begin_DATE
                                                                                                 AND a.End_DATE
                                                                            AND Status_CODE = 'Y') AS m
																	LEFT OUTER JOIN
																	(SELECT a.*
																		FROM AHIS_Y1 a
																		WHERE a.MemberMci_IDNO =
																				CAST (
																					@Ac_Recipient_ID AS NUMERIC) 
																			AND TypeAddress_CODE =
																					'C'
																			AND @Ad_Run_DATE BETWEEN a.Begin_DATE
																									AND a.End_DATE
																			AND Status_CODE = 'Y') AS c
																	ON m.MemberMci_IDNO = c.MemberMci_IDNO
                                                              WHERE (CASE
                                                                        WHEN m.Line1_ADDR =
                                                                                c.Line1_ADDR
                                                                             AND m.Line2_ADDR =
                                                                                    c.Line2_ADDR
                                                                             AND m.City_ADDR =
                                                                                    c.City_ADDR
                                                                             AND m.State_ADDR =
                                                                                    c.State_ADDR
                                                                             AND SUBSTRING(LTRIM(RTRIM(m.Zip_ADDR)),1,5)  =
                                                                                    SUBSTRING(LTRIM(RTRIM(c.Zip_ADDR)),1,5)
                                                                             AND m.Country_ADDR =
                                                                                    c.Country_ADDR
                                                                        THEN
                                                                           0
																		WHEN c.Line1_ADDR = '' THEN 1
                                                                        ELSE
                                                                           1
                                                                     END) = 1) a) a
                                      
                        END
                     ELSE IF @Lc_AddressHierarchy_CODE IN ('4', 'Y', '') 
                        BEGIN

                           SET @GetAddress_CUR =
                                  CURSOR FOR
                                     SELECT Line1_ADDR,
                                            Line2_ADDR,                             
                                            State_ADDR,
                                            Zip_ADDR,
                                            City_ADDR,
                                            Status_CODE,
                                            TypeAddress_CODE,
                                            (CASE WHEN a.addr_rnm = 1 THEN 1 ELSE 0 END) Ind_ADDR
                                       FROM (SELECT ROW_NUMBER ()
                                                    OVER (
                                                       PARTITION BY a.MemberMci_IDNO
                                                       ORDER BY addr_hrchy,
                                                                Status_CODE DESC,
                                                                TransactionEventSeq_NUMB DESC,
                                                                Update_DTTM DESC)
                                                       addr_rnm,
                                                    a.*
                                               FROM (SELECT (CASE
                                                                WHEN TypeAddress_CODE = 'M'
                                                                     AND Status_CODE = 'Y'
                                                                     AND a.End_DATE >= @Ad_Run_DATE
                                                                THEN
                                                                   1
                                                                WHEN TypeAddress_CODE = 'R'
                                                                     AND Status_CODE = 'Y'
                                                                     AND a.End_DATE >= @Ad_Run_DATE
                                                                THEN
                                                                   2
                                                                WHEN TypeAddress_CODE = 'M'
                                                                     AND Status_CODE = 'P'
                                                                     AND a.End_DATE >= @Ad_Run_DATE
                                                                     AND @Ac_Notice_ID = @Lc_Notice_ID_LOC_01
                                                                THEN
                                                                   3
                                                                WHEN TypeAddress_CODE = 'R'
                                                                     AND Status_CODE = 'P'
                                                                     AND a.End_DATE >= @Ad_Run_DATE
                                                                     AND @Ac_Notice_ID = @Lc_Notice_ID_LOC_01
                                                                THEN
                                                                   4
                                                                WHEN TypeAddress_CODE = 'M'
																	 AND a.End_DATE < @Ad_Run_DATE 
																	 AND @Ac_Notice_ID = @Lc_Notice_ID_LOC_01
                                                                THEN
                                                                   5
                                                                WHEN TypeAddress_CODE = 'R' 
																	 AND @Ac_Notice_ID = @Lc_Notice_ID_LOC_01
                                                                THEN
                                                                   6
                                                                ELSE
                                                                   7
                                                             END)
                                                               addr_hrchy,
                                                            a.*
                                                       FROM (SELECT ROW_NUMBER ()
                                                                    OVER (
                                                                       PARTITION BY a.MemberMci_IDNO
                                                                       ORDER BY     
                                                                          Status_CODE DESC,
                                                                          TransactionEventSeq_NUMB DESC,
                                                                          Update_DTTM DESC)
                                                                       ronm,
                                                                    a.*
                                                               FROM (SELECT ROW_NUMBER ()
                                                                            OVER (
                                                                               PARTITION BY a.MemberMci_IDNO,
                                                                                            TypeAddress_CODE
                                                                               ORDER BY
                                                                                  Status_CODE DESC,
                                                                                  TransactionEventSeq_NUMB DESC,
                                                                                  Update_DTTM DESC)
                                                                               rnm,
                                                                            a.*
                                                                       FROM (SELECT a.*
                                                                               FROM AHIS_Y1 a
                                                                              WHERE a.MemberMci_IDNO =
                                                                                       CAST (
                                                                                          @Ac_Recipient_ID AS NUMERIC) 
                                                                                    AND TypeAddress_CODE IN
                                                                                           ('M',
                                                                                            'R')
                                                                                    AND (	 (	   @Ad_Run_DATE BETWEEN a.Begin_DATE
																												    AND a.End_DATE
																							   AND (Status_CODE IN('Y') OR (Status_CODE IN('P') AND @Ac_Notice_ID = @Lc_Notice_ID_LOC_01))
																						     )
                                                                                      
                                                                                         )) AS a) a
                                                              WHERE rnm = 1) a) a) a
                                      
                        END
            END
         -- Cursor that gets Office Address Details from FIPS_Y1
         -- FIPS
         ELSE IF (@Lc_MailRecipient_CODE = '2')
            BEGIN
                DECLARE
                    @Ac_Fips_CODE VARCHAR (MAX),
                    @Ln_FipsCodeLen_NUMB NUMERIC,
                    @Ln_diff NUMERIC,
                    @i NUMERIC = 0,
                    @Ln_Zero VARCHAR (7) = ''

                SET @Ac_Fips_CODE = CAST (@Ac_Recipient_ID AS VARCHAR)
                SET @Ln_FipsCodeLen_NUMB = LEN (@Ac_Fips_CODE)
                SET @Ln_diff = 7 - @Ln_FipsCodeLen_NUMB

                IF @Ln_diff <> 0
                    BEGIN
                    WHILE @i < @Ln_diff
                    BEGIN
                        SET @Ln_Zero = @Ln_Zero + '0'
                        SET @I = @i + 1
                    END
                    END

                SET @Ac_Fips_CODE = @Ln_Zero + @Ac_Fips_CODE

                SET @GetAddress_CUR =
                        CURSOR FOR
                        (SELECT line1_ADDR AS addr_line1,
                                f.Line2_ADDR AS addr_line2,
                                f.State_ADDR AS addr_State,
                                f.Zip_ADDR AS addr_zip,
                                f.City_ADDR AS addr_City,
                                'Y' AS cd_status,
                                'M' AS cd_type_address,
                                1 AS ind_addr
                            FROM FIPS_Y1 f
                            WHERE f.Fips_CODE = @Ac_Fips_CODE                   --@Ac_Recipient_ID
                                AND ( (f.TypeAddress_CODE = @Lc_TypeAddress_state_CODE
                                        AND f.SubTypeAddress_CODE  = @Lc_Sub_TypeAddress_crg_CODE
                                        AND (SUBSTRING (
                                                @Ac_Fips_CODE 
                                                            ,
                                                3,
                                                3) = @Ls_IVDOutOfStateCountyFips_CODE
                                            OR SUBSTRING (
                                                    @Ac_Fips_CODE ,
                                                    3,
                                                    3)
                                                    IS NULL)
                                        AND (SUBSTRING (
                                                @Ac_Fips_CODE  ,
                                                6,
                                                2) = @Ls_IVDOutOfStateOfficeFips_00_CODE
                                            OR SUBSTRING (
                                                    @Ac_Fips_CODE ,
                                                    6,
                                                    2)
                                                    IS NULL))
                                        OR (f.TypeAddress_CODE = @Lc_TypeAddress_Locate_CODE
                                            AND f.SubTypeAddress_CODE =
                                                @Lc_Sub_TypeAddress_c01_CODE
                                            AND (SUBSTRING (
                                                    @Ac_Fips_CODE ,
                                                    3,
                                                    5) <> @Ls_IVDOutOfStateCountyFips_CODE
                                                OR SUBSTRING (
                                                    @Ac_Fips_CODE ,
                                                    3,
                                                    5)
                                                    IS NOT NULL))
                                        OR (f.StateFips_CODE > @Ls_IVDOutOfStateFips_us_max_CODE
                                            AND f.TypeAddress_CODE = @Lc_TypeAddress_Int_CODE
                                            AND f.SubTypeAddress_CODE = @Lc_Sub_TypeAddress_Int_CODE)
                                         OR (f.StateFips_CODE = @Ls_IVDOutOfStateFips_Tribal_CODE
                                            AND f.TypeAddress_CODE = @Lc_TypeAddress_Trb_CODE
                                            AND f.SubTypeAddress_CODE = @Lc_Sub_TypeAddress_T01_CODE))
                                AND f.EndValidity_DATE = @Ld_High_Date)
            END
         -- Cursor that gets other party Address Details from OTHP_Y1
         ELSE IF (@Lc_MailRecipient_CODE = '3')
            BEGIN
				--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - Start
				SELECT @Ac_Recipient_ID = CAST(O.AddrOthp_IDNO  AS CHAR(10))
					FROM OTHX_Y1 O
					WHERE O.OtherParty_IDNO = @Ln_Recipient_IDNO    
					AND O.EndValidity_DATE = @Ld_High_Date
					AND ((O.TypeAddr_CODE = @Lc_TypeAddrZ_CODE 
							AND @Ac_Notice_ID = @Lc_NoticeEnf01_ID 
							AND @Ac_Recipient_CODE = @Lc_RecipientSi_CODE) 
						OR (O.TypeAddr_CODE = @Lc_TypeAddrV_CODE 
							AND @Ac_Notice_ID = @Lc_NoticeEnf03_ID 
							AND @Ac_Recipient_CODE = @Lc_RecipientOe_CODE))
				--13456 - OTHP - Corporate and Health Plan Administrator addresses not working as designed Fix - End	
							
                SET @GetAddress_CUR =
                    CURSOR FOR
                        SELECT Line1_ADDR AS addr_line1,
                                Line2_ADDR AS addr_line2,
                                State_ADDR AS addr_state,
                                zip_ADDR AS addr_zip,
                                City_ADDR AS addr_city,
                                Verified_INDC AS cd_status,
                                'M' AS cd_type_address,
                                1 AS ind_addr
                            FROM OTHP_Y1
                        WHERE OtherParty_IDNO = CAST (@Ac_Recipient_ID AS NUMERIC)
                                AND EndValidity_DATE = @Ld_High_Date;
            END


         OPEN @GetAddress_CUR;

         FETCH NEXT FROM @GetAddress_CUR   INTO @Ls_Line1_ADDR, @Ls_Line2_ADDR, @LS_State_ADDR, @Ls_Zip_ADDR, @Ls_City_ADDR, @Lc_Status_CODE, @Lc_TypeAddress_CODE, @Lc_Addr_INDC;

         WHILE @@FETCH_STATUS = 0
         BEGIN
            INSERT INTO #MemberAddressDetails_P1
               SELECT @Ls_Line1_ADDR,
                      @Ls_Line2_ADDR,
                      @LS_State_ADDR,
                      @Ls_City_ADDR,
                      @Ls_Zip_ADDR,
                      @Lc_TypeAddress_CODE,
                      @Lc_Status_CODE,
                      @Lc_Addr_INDC;

            FETCH NEXT FROM @GetAddress_CUR   INTO @Ls_Line1_ADDR, @Ls_Line2_ADDR, @LS_State_ADDR, @Ls_Zip_ADDR,
                                                  @Ls_City_ADDR, @Lc_Status_CODE, @Lc_TypeAddress_CODE, @Lc_Addr_INDC;
         END

         CLOSE @GetAddress_CUR;
         DEALLOCATE @GetAddress_CUR;

         SELECT * FROM #MemberAddressDetails_P1;

         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Ln_Error_NUMB INT, @Ln_ErrorLine_NUMB INT;
         SET @Ln_Error_NUMB = ERROR_NUMBER ();
         SET @Ln_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Ln_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME   = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT         = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT     = @Ls_Sqldata_TEXT,
                                                       @An_Error_NUMB       = @Ln_Error_NUMB,
                                                       @An_ErrorLine_NUMB   = @Ln_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
