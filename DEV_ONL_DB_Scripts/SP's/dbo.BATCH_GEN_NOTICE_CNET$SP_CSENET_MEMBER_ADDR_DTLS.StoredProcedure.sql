/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_CNET$SP_CSENET_MEMBER_ADDR_DTLS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_CNET$SP_CSENET_MEMBER_ADDR_DTLS
Programmer Name	:	IMP Team.
Description		:	
Frequency		:	
Developed On	:	5/3/2012
Called By		:	
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_CNET$SP_CSENET_MEMBER_ADDR_DTLS] 
(
   @An_TransHeader_IDNO                   NUMERIC (12),
   @Ad_Transaction_DATE                   DATE,
   @Ac_IVDOutOfStateFips_CODE             CHAR (2),
   @Ac_MemberSex_CODE                     CHAR (1),
   @Ac_Relationship_CODE                  CHAR (1),
   @Ac_ChildRelationshipNcp_CODE          CHAR (1),
   @As_Prefix_TEXT                        VARCHAR (70),
   @Ac_Msg_CODE                           CHAR (5) OUTPUT,
   @As_DescriptionError_TEXT              VARCHAR (4000) OUTPUT)
AS
   BEGIN
      DECLARE
         @Ls_Space_TEXT CHAR(1) = ' ',
         @Ls_RelationshipCaseDependent_TEXT CHAR (1) = 'D',
         @Lc_StatusFailed_CODE CHAR(1) = 'F',
         @Lc_StatusSuccess_CODE CHAR(1) = 'S',
         @Ls_DependentRelationshipNcp_TEXT CHAR(1) = 'C',
         @Ls_Procedure_NAME VARCHAR(100) = 'BATCH_GEN_NOTICE_CNET.BATCH_GEN_NOTICE_CNET$SP_CSENET_MEMBER_ADDR_DTLS ';

      DECLARE
         @Ls_DescriptionError_TEXT VARCHAR (4000),
         @Ls_Sql_TEXT VARCHAR (200),
         @Ls_Sqldata_TEXT VARCHAR (400);

      BEGIN TRY
         SET @Ac_Msg_CODE = NULL;
         SET @As_DescriptionError_TEXT = NULL;
         
         SET @Ls_Sql_TEXT = 'LOCAL TEMPORARY NDEL';
         SET @Ls_Sqldata_TEXT = ' TransHeader_IDNO='
                  + CAST(@An_TransHeader_IDNO AS VARCHAR)
                  + ' IVDOutOfStateFips_CODE='
                  + ISNULL (@Ac_IVDOutOfStateFips_CODE, '')
                  + ' MemberSex_CODE='
                  + ISNULL (@Ac_MemberSex_CODE, '');

         DECLARE @Ndel_P1 TABLE
			  (
				 Element_NAME    VARCHAR(100),
				 Element_Value   VARCHAR(100)
			  );
 
         SET @Ls_Sql_TEXT = 'EXISTS CHECK CNCB_CNLB';
         IF (EXISTS
                (SELECT 1
                   FROM    CNCB_Y1 NCP
                        JOIN
                           CNLB_Y1 NCPL
                        ON NCP.TransHeader_IDNO = NCPL.TransHeader_IDNO
                           AND NCP.Transaction_DATE = NCPL.Transaction_DATE
                           AND NCP.IVDOutOfStateFips_CODE =
                                  NCPL.IVDOutOfStateFips_CODE
                  WHERE NCP.TransHeader_IDNO = @An_TransHeader_IDNO
                        AND NCP.Transaction_DATE = @Ad_Transaction_DATE
                        AND NCP.IVDOutOfStateFips_CODE =
                               @Ac_IVDOutOfStateFips_CODE
                        AND NCP.MemberSex_CODE = @Ac_MemberSex_CODE)
						AND @Ac_Relationship_CODE IS NOT NULL)
            BEGIN
               IF EXISTS
                     (SELECT 1
                        FROM    CNCB_Y1 NCP
                             JOIN
                                CNLB_Y1 NCPL
                             ON NCP.TransHeader_IDNO = NCPL.TransHeader_IDNO
                                AND NCP.Transaction_DATE =
                                       NCPL.Transaction_DATE
                                AND NCP.IVDOutOfStateFips_CODE =
                                       NCPL.IVDOutOfStateFips_CODE
                       WHERE NCP.TransHeader_IDNO = @An_TransHeader_IDNO
                             AND NCP.Transaction_DATE = @Ad_Transaction_DATE
                             AND NCP.IVDOutOfStateFips_CODE =
                                    @Ac_IVDOutOfStateFips_CODE
                             AND NCP.MemberSex_CODE = @Ac_MemberSex_CODE
                             AND RTRIM (NCPL.MailingLine1_ADDR) != ''
                             AND RTRIM (NCPL.MailingCity_ADDR) != ''
                             AND RTRIM (NCPL.MailingState_ADDR) != '')
               BEGIN
				  SET @Ls_Sql_TEXT = 'SELECT CNCB_CNLB - 1';

				  INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
					SELECT pvt.Element_NAME, pvt.Element_Value
					  FROM (SELECT CAST(b.MailingLine1_ADDR AS VARCHAR(100)) AS Line1_ADDR,
								  CAST(b.MailingLine2_ADDR AS VARCHAR(100)) AS Line2_ADDR,
								  CAST(b.MailingCity_ADDR AS VARCHAR(100)) AS City_ADDR,
								  CAST(b.MailingState_ADDR AS VARCHAR(100)) AS State_ADDR,
								  CAST(b.MailingZip_ADDR AS VARCHAR(100)) AS Zip_ADDR,   
								  CASE WHEN b.MailingConfirmed_CODE ='Y' THEN
										CAST('X' AS VARCHAR(100)) 
										ELSE CAST('' AS VARCHAR(100))
								  END  AS verified_addr_yes_indc,
								  CAST(b.EffectiveMailing_DATE AS VARCHAR(100)) AS Addr_verified_DATE,
								  CAST(b.Employer_NAME AS VARCHAR(100)) AS Employer_NAME,
								  CAST(b.EmployerLine1_ADDR AS VARCHAR(100)) AS Employer_Line1_ADDR,
								  CAST(b.EmployerLine2_ADDR AS VARCHAR(100)) AS Employer_Line2_ADDR,
								  CAST(b.EmployerCity_ADDR AS VARCHAR(100)) AS Employer_City_ADDR,
								  CAST(b.EmployerState_ADDR AS VARCHAR(100)) AS Employer_State_ADDR,
								  CAST(b.EmployerZip_ADDR AS VARCHAR(100)) AS  Employer_Zip_ADDR,
								  CAST(b.EffectiveEmployer_DATE AS VARCHAR(100)) AS Employer_Status_DATE,
								  CAST(b.EmployerConfirmed_INDC AS VARCHAR(100)) AS Employer_Status_CODE,
								  CAST(b.HomePhone_NUMB AS VARCHAR(100)) AS HomePhone_NUMB,
								  CAST(b.WorkPhone_NUMB AS VARCHAR(100)) AS WorkPhone_NUMB,
								  CAST(a.First_NAME AS VARCHAR(100)) AS First_NAME,
								  CAST(a.Middle_NAME AS VARCHAR(100)) AS Middle_NAME,
								  CAST(a.Last_NAME AS VARCHAR(100)) AS Last_NAME,
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS BirthCity_NAME,
								  
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS birthCity_State_Country_TEXT,
								  CAST(a.Birth_DATE AS VARCHAR(100)) AS Birth_DATE,
								  CAST(a.MemberSsn_NUMB AS VARCHAR(100)) AS Ssn_NUMB,
								  CAST(b.Alias1First_NAME AS VARCHAR(100)) AS FirstAlias_NAME,
								  CAST(b.Alias1Middle_NAME AS VARCHAR(100)) AS MaidenAlias_NAME,
								  CAST(b.Alias1Last_NAME AS VARCHAR(100)) AS LastAlias_NAME
						  FROM CNCB_Y1  AS a, CNLB_Y1  AS b  
						  WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO 
						    AND a.Transaction_DATE =  @Ad_Transaction_DATE  
						    AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE 
						    AND a.MemberSex_CODE = @Ac_MemberSex_CODE 
						    AND b.TransHeader_IDNO = a.TransHeader_IDNO 
						    AND b.Transaction_DATE = a.Transaction_DATE 
						    AND b.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE) U UNPIVOT (Element_VALUE FOR Element_NAME IN (
                                   U.Line1_ADDR, U.Line2_ADDR, U.City_ADDR, U.State_ADDR, 
                                   U.Zip_ADDR, verified_addr_yes_indc, Addr_verified_DATE,U.Employer_NAME, U.Employer_Line1_ADDR, U.Employer_Line2_ADDR, 
                                   U.Employer_City_ADDR, U.Employer_State_ADDR, U.Employer_Zip_ADDR, U.Employer_Status_DATE, U.Employer_Status_CODE, U.HomePhone_NUMB, 
                                   U.WorkPhone_NUMB, U.First_NAME, U.Middle_NAME, U.Last_NAME,
                                   U.BirthCity_NAME, U.Birth_DATE, U.Ssn_NUMB, U.FirstAlias_NAME,
                                   U.MaidenAlias_NAME, U.LastAlias_NAME)) pvt;
               END
               ELSE
               BEGIN
                  SET @Ls_Sql_TEXT = 'SELECT CNCB_CNLB - 2';

                  INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
					SELECT pvt.Element_NAME, pvt.Element_Value
					  FROM (SELECT CAST(b.ResidentialLine1_ADDR AS VARCHAR(100)) AS Line1_ADDR,
								  CAST(b.ResidentialLine2_ADDR AS VARCHAR(100)) AS Line2_ADDR,
								  CAST(b.ResidentialCity_ADDR AS VARCHAR(100)) AS City_ADDR,
								  CAST(b.ResidentialState_ADDR AS VARCHAR(100)) AS State_ADDR,
								  CAST(b.ResidentialZip_ADDR AS VARCHAR(100)) AS Zip_ADDR,  
								  CASE WHEN b.ResidentialConfirmed_CODE ='Y' THEN
										CAST('X' AS VARCHAR(100)) 
										ELSE CAST('' AS VARCHAR(100))
								  END  AS verified_addr_yes_indc,
								  CAST(b.EffectiveResidential_DATE AS VARCHAR(100)) AS Addr_verified_DATE, 
								  CAST(b.Employer_NAME AS VARCHAR(100)) AS Employer_NAME,
								  CAST(b.EmployerLine1_ADDR AS VARCHAR(100)) AS Employer_Line1_ADDR,
								  CAST(b.EmployerLine2_ADDR AS VARCHAR(100)) AS Employer_Line2_ADDR,
								  CAST(b.EmployerCity_ADDR AS VARCHAR(100)) AS Employer_City_ADDR,
								  CAST(b.EmployerState_ADDR AS VARCHAR(100)) AS Employer_State_ADDR,
								  CAST(b.EmployerZip_ADDR AS VARCHAR(100)) AS  Employer_Zip_ADDR,
								  CAST(b.EffectiveEmployer_DATE AS VARCHAR(100)) AS Employer_Status_DATE,
								  CAST(b.EmployerConfirmed_INDC AS VARCHAR(100)) AS Employer_Status_CODE,
								  CAST(b.HomePhone_NUMB AS VARCHAR(100)) AS HomePhone_NUMB,
								  CAST(b.WorkPhone_NUMB AS VARCHAR(100)) AS WorkPhone_NUMB,
								  CAST(a.First_NAME AS VARCHAR(100)) AS First_NAME,
								  CAST(a.Middle_NAME AS VARCHAR(100)) AS Middle_NAME,
								  CAST(a.Last_NAME AS VARCHAR(100)) AS Last_NAME,
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS BirthCity_NAME,
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS birthCity_State_Country_TEXT,
								  CAST(a.Birth_DATE AS VARCHAR(100)) AS Birth_DATE,
								  CAST(a.MemberSsn_NUMB AS VARCHAR(100)) AS Ssn_NUMB,
								  CAST(b.Alias1First_NAME AS VARCHAR(100)) AS FirstAlias_NAME,
								  CAST(b.Alias1Middle_NAME AS VARCHAR(100)) AS MaidenAlias_NAME,
								  CAST(b.Alias1Last_NAME AS VARCHAR(100)) AS LastAlias_NAME
						  FROM CNCB_Y1  AS a, CNLB_Y1  AS b  
						  WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO 
						    AND a.Transaction_DATE =  @Ad_Transaction_DATE   
						    AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE 
						    AND a.MemberSex_CODE = @Ac_MemberSex_CODE 
						    AND b.TransHeader_IDNO = a.TransHeader_IDNO 
						    AND b.Transaction_DATE = a.Transaction_DATE 
						    AND b.IVDOutOfStateFips_CODE = a.IVDOutOfStateFips_CODE) U UNPIVOT (Element_VALUE FOR Element_NAME IN (
                                   U.Line1_ADDR, U.Line2_ADDR, U.City_ADDR, U.State_ADDR, 
                                   U.Zip_ADDR, verified_addr_yes_indc, Addr_verified_DATE, U.Employer_NAME, U.Employer_Line1_ADDR, U.Employer_Line2_ADDR, 
                                   U.Employer_City_ADDR, U.Employer_State_ADDR, U.Employer_Zip_ADDR, Employer_Status_DATE, Employer_Status_CODE,  U.HomePhone_NUMB, 
                                   U.WorkPhone_NUMB, U.First_NAME, U.Middle_NAME, U.Last_NAME,
                                   U.BirthCity_NAME, U.Birth_DATE, U.Ssn_NUMB, U.FirstAlias_NAME,
                                   U.MaidenAlias_NAME, U.LastAlias_NAME)) pvt;
			   END
            END
         ELSE
            BEGIN
               SET @Ls_Sql_TEXT = 'SELECT CPTB_Y1';

               INSERT INTO @Ndel_P1 (Element_NAME, Element_Value)
					SELECT pvt.Element_NAME, pvt.Element_Value
					  FROM (SELECT CAST(a.ParticipantLine1_ADDR AS VARCHAR(100)) AS Line1_ADDR,
								  CAST(a.ParticipantLine2_ADDR AS VARCHAR(100)) AS Line2_ADDR,
								  CAST(a.ParticipantCity_ADDR AS VARCHAR(100)) AS City_ADDR,
								  CAST(a.ParticipantState_ADDR AS VARCHAR(100)) AS State_ADDR,
								  CAST(a.ParticipantZip_ADDR AS VARCHAR(100)) AS Zip_ADDR, 
								   CASE WHEN a.ConfirmedAddress_INDC ='Y' THEN
										CAST('X' AS VARCHAR(100)) 
										ELSE CAST('' AS VARCHAR(100))
								  END  AS verified_addr_yes_indc,
								  CAST(a.ConfirmedAddress_DATE AS VARCHAR(100)) AS Addr_verified_DATE, 
								    
								  CAST(a.Employer_NAME AS VARCHAR(100)) AS Employer_NAME,
								  CAST(a.EmployerLine1_ADDR AS VARCHAR(100)) AS Employer_Line1_ADDR,
								  CAST(a.EmployerLine2_ADDR AS VARCHAR(100)) AS Employer_Line2_ADDR,
								  CAST(a.EmployerCity_ADDR AS VARCHAR(100)) AS Employer_City_ADDR,
								  CAST(a.EmployerState_ADDR AS VARCHAR(100)) AS Employer_State_ADDR,
								  CAST(a.EmployerZip_ADDR AS VARCHAR(100)) AS  Employer_Zip_ADDR,
								  CAST(a.ConfirmedEmployer_DATE AS VARCHAR(100)) AS Employer_Status_DATE,
								  CAST(a.ConfirmedEmployer_INDC AS VARCHAR(100)) AS Employer_Status_CODE,
								  CAST('' AS VARCHAR(100)) AS HomePhone_NUMB,
								  CAST(a.WorkPhone_NUMB AS VARCHAR(100)) AS WorkPhone_NUMB,
								  CAST(a.First_NAME AS VARCHAR(100)) AS First_NAME,
								  CAST(a.Middle_NAME AS VARCHAR(100)) AS Middle_NAME,
								  CAST(a.Last_NAME AS VARCHAR(100)) AS Last_NAME,
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS BirthCity_NAME,
								  
								  CAST(a.PlaceOfBirth_NAME AS VARCHAR(100)) AS birthCity_State_Country_TEXT,
								  CAST(a.Birth_DATE AS VARCHAR(100)) AS Birth_DATE,
								  CAST(a.MemberSsn_NUMB AS VARCHAR(100)) AS Ssn_NUMB,
								  CAST(@Ls_Space_TEXT AS VARCHAR(100)) AS FirstAlias_NAME,
								  CAST(@Ls_Space_TEXT AS VARCHAR(100)) AS MaidenAlias_NAME,
								  CAST(@Ls_Space_TEXT AS VARCHAR(100)) AS LastAlias_NAME
						  FROM CPTB_Y1  AS a
						  WHERE a.TransHeader_IDNO = @An_TransHeader_IDNO 
						    AND a.Transaction_DATE =  @Ad_Transaction_DATE  
						    AND a.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE 
						    AND ((@Ac_Relationship_CODE IS NULL AND a.Relationship_CODE <> @Ls_RelationshipCaseDependent_TEXT)
								OR (@Ac_Relationship_CODE IS NOT NULL AND a.Relationship_CODE = @Ac_Relationship_CODE))
						    AND a.MemberSex_CODE = ISNULL(@Ac_MemberSex_CODE, a.MemberSex_CODE)
						    
						    AND EXISTS   
							    (SELECT 1 AS expr  
								   FROM CPTB_Y1 c  
								  WHERE c.TransHeader_IDNO = @An_TransHeader_IDNO 
										AND c.Transaction_DATE = @Ad_Transaction_DATE 
										AND c.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE 
										AND c.Relationship_CODE = @Ls_RelationshipCaseDependent_TEXT 
										AND ((@Ac_Relationship_CODE IS NULL AND c.ChildRelationshipNcp_CODE <> @Ls_DependentRelationshipNcp_TEXT) --   NOT A NATURAL PARENT
											 OR (@Ac_Relationship_CODE IS NOT NULL AND c.ChildRelationshipNcp_CODE = @Ac_ChildRelationshipNcp_CODE))
								 )
						    ) U UNPIVOT (Element_VALUE FOR Element_NAME IN (
                                   U.Line1_ADDR, U.Line2_ADDR, U.City_ADDR, U.State_ADDR, 
                                   U.Zip_ADDR, verified_addr_yes_indc, Addr_verified_DATE, U.Employer_NAME, U.Employer_Line1_ADDR, U.Employer_Line2_ADDR, 
                                   U.Employer_City_ADDR, U.Employer_State_ADDR, U.Employer_Zip_ADDR,Employer_Status_DATE, Employer_Status_CODE, U.HomePhone_NUMB, 
                                   U.WorkPhone_NUMB, U.First_NAME, U.Middle_NAME, U.Last_NAME,
                                   U.BirthCity_NAME, U.Birth_DATE, U.Ssn_NUMB, U.FirstAlias_NAME,
                                   U.MaidenAlias_NAME, U.LastAlias_NAME)) pvt;
            END;

		 UPDATE @Ndel_P1
            SET Element_NAME = RTRIM(@As_Prefix_TEXT) + '_' + Element_NAME;

         INSERT INTO #NoticeElementsData_P1 (Element_NAME, Element_Value)
            SELECT t.Element_NAME, t.Element_Value
              FROM @Ndel_P1 t;
        
         SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
         
      END TRY
      BEGIN CATCH
         SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE
            @Li_Error_NUMB INT = ERROR_NUMBER (),
            @Li_ErrorLine_NUMB INT = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =
                      SUBSTRING (ERROR_MESSAGE (), 1, 200);
            END

         EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION @As_Procedure_NAME = @Ls_Procedure_NAME,
                                                       @As_ErrorMessage_TEXT = @Ls_DescriptionError_TEXT,
                                                       @As_Sql_TEXT = @Ls_Sql_TEXT,
                                                       @As_Sqldata_TEXT = @Ls_SqlData_TEXT,
                                                       @An_Error_NUMB = @Li_Error_NUMB,
                                                       @An_ErrorLine_NUMB = @Li_ErrorLine_NUMB,
                                                       @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT ;

         SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
      END CATCH
   END

GO
