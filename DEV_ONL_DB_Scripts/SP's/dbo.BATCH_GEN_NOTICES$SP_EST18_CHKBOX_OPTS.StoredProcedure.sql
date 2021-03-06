/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICES$SP_EST18_CHKBOX_OPTS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICES$SP_EST18_CHKBOX_OPTS](
 @An_Case_IDNO             NUMERIC(6),
 @An_Otherparty_IDNO       NUMERIC(10),
 @An_NcpMemberMci_IDNO     NUMERIC(10),
 @An_CpMemberMci_IDNO      NUMERIC(10),
 @Ac_ActivityMajor_CODE    CHAR(4),
 @Ac_ReasonStatus_CODE     CHAR(2) = ' ',
 @An_MajorIntSeq_NUMB      NUMERIC(5),
 @Ad_Run_DATE              DATE,
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
 )
AS
 BEGIN
  SET NOCOUNT ON;

  DECLARE @Lc_StatusFailed_CODE         CHAR(1) = 'F',
          @Lc_StatusSuccess_CODE        CHAR(1) = 'S',
          @Lc_MailingTypeAddress_CODE   CHAR(1) = 'M',
          @Lc_Status_CODE               CHAR(1) = 'Y',
          @Lc_CaseRelationshipCP_CODE   CHAR(1) = 'C',
          @Lc_CaseRelationshipNCP_CODE  CHAR(1) = 'A',
          @Lc_CaseRelationshipPF_CODE   CHAR(1) = 'P',
          @Lc_MemberStatusActive_CODE   CHAR(1) = 'A',
          @Lc_MemberStatusInActive_CODE CHAR(1) = 'I',
          @Lc_CaseRelationshipDP_CODE   CHAR(1) = 'D',
          @Lc_StatusCaseOpen_CODE       CHAR(1) = 'O',
          @Lc_BankruptcyType13_CODE     CHAR(2) = '13',
          @Lc_Notice_ID                 CHAR(8) = 'ENF-01',
          @Ls_Procedure_NAME            VARCHAR(100) = 'BATCH_GEN_NOTICES$SP_EST18_CHKBOX_OPTS',
          @Ld_High_DATE                 DATE = '12/31/9999',
          @Ld_Low_DATE                  DATE = '01/01/0001';
  DECLARE @Ln_Error_NUMB     NUMERIC(11),
          @Ln_ErrorLine_NUMB NUMERIC(11),
          @Ls_Sql_TEXT       VARCHAR(100),
          @Ls_Sqldata_TEXT   VARCHAR (1000),
          @Ls_DescriptionError_TEXT     VARCHAR(4000) = '';
  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;

   IF @Ac_ActivityMajor_CODE = 'MAPP'
    BEGIN
     SET @An_Otherparty_IDNO = @An_NcpMemberMci_IDNO;
    END
   SET @Ls_Sql_TEXT = 'INSERT #NoticeElementsData_P1';
   SET @Ls_Sqldata_TEXT = 'Case_IDNO =	' + ISNULL(CAST(@An_Case_IDNO AS VARCHAR), '') + ', Othpsource_IDNO = ' + ISNULL(CAST(@An_Otherparty_IDNO AS VARCHAR), '') + ', NcpMemberMci_IDNO = ' + ISNULL(CAST(@An_NcpMemberMci_IDNO AS VARCHAR), '');

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_VALUE)
   (SELECT Element_NAME,
           Element_VALUE
      FROM (SELECT CONVERT(VARCHAR(70), k.new_pet_lkcAddrver_CODE) AS new_pet_lkcAddrver_CODE,
                   CONVERT(VARCHAR(70), k.mod_pet_lkcaddrver_code) AS mod_pet_lkcaddrver_code,
                   CONVERT(VARCHAR(70), k.compt_pet_lkcaddrver_code) AS compt_pet_lkcaddrver_code,
                   CONVERT(VARCHAR(70), k.new_pet_mailaddrver_code) AS new_pet_mailaddrver_code,
                   CONVERT(VARCHAR(70), k.mod_pet_mailaddrver_code) AS mod_pet_mailaddrver_code,
                   CONVERT(VARCHAR(70), k.compt_pet_mailaddrver_code) AS compt_pet_mailaddrver_code,
                   CONVERT(VARCHAR(70), k.new_pet_ssn_CODE) AS new_pet_ssn_CODE,
                   CONVERT(VARCHAR(70), k.mod_pet_ssn_CODE) AS mod_pet_ssn_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_ssn_code) AS compt_pet_ssn_code,
                   CONVERT(VARCHAR(70), k.cpncpaddrnotsame_code) AS cpncpaddrnotsame_code,
                   CONVERT(VARCHAR(70), k.new_pet_ivdclient_code) AS new_pet_ivdclient_code,
                   CONVERT(VARCHAR(70), k.mod_pet_ivdclient_code) AS mod_pet_ivdclient_code,
                   CONVERT(VARCHAR(70), k.compt_pet_ivdclient_code) AS compt_pet_ivdclient_code,
                   CONVERT(VARCHAR(70), k.new_pet_ncpexclude_CODE) AS new_pet_ncpexclude_CODE,
                   CONVERT(VARCHAR(70), k.mod_pet_ncpexclude_CODE) AS mod_pet_ncpexclude_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_ncpexclude_CODE) AS compt_pet_ncpexclude_CODE,
                   CONVERT(VARCHAR(70), k.curr_ord_revw_eligible_code) AS curr_ord_revw_eligible_code,
                   CONVERT(VARCHAR(70), k.petitiontoaddchild_code) AS petitiontoaddchild_code,
                   CONVERT(VARCHAR(70), k.mod_pet_ncpreleasedate_CODE) AS mod_pet_ncpreleasedate_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_ncpreleasedate_CODE) AS compt_pet_ncpreleasedate_CODE,
                   CONVERT(VARCHAR(70), k.release_date) AS release_date,
                   CONVERT(VARCHAR(70), k.new_pet_ncpnocapias_CODE) AS new_pet_ncpnocapias_CODE,
                   CONVERT(VARCHAR(70), k.mod_pet_ncpnocapias_CODE) AS mod_pet_ncpnocapias_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_ncpnocapias_CODE) AS compt_pet_ncpnocapias_CODE,
                   CONVERT(VARCHAR(70), k.mod_pet_ncpnotbkrpt_CODE) AS mod_pet_ncpnotbkrpt_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_ncpnotbkrpt_CODE) AS compt_pet_ncpnotbkrpt_CODE,
                   CONVERT(VARCHAR(70), k.ChldExcludetanfCase_CODE) AS ChldExcludetanfCase_CODE,
                   CONVERT(VARCHAR(70), k.Iwoissue_DATE) AS iwoissue_DATE,
                   CONVERT(VARCHAR(70), k.mod_pet_iwo_CODE) AS mod_pet_iwo_CODE,
                   CONVERT(VARCHAR(70), k.compt_pet_iwo_CODE) AS compt_pet_iwo_CODE
              FROM(SELECT MAX(new_pet_lkcAddrver_CODE) AS new_pet_lkcAddrver_CODE,
                          MAX(mod_pet_lkcaddrver_code) AS mod_pet_lkcaddrver_code,
                          MAX(compt_pet_lkcaddrver_code) AS compt_pet_lkcaddrver_code,
                          MAX(new_pet_mailaddrver_code) AS new_pet_mailaddrver_code,
                          MAX(mod_pet_mailaddrver_code) AS mod_pet_mailaddrver_code,
                          MAX(compt_pet_mailaddrver_code) AS compt_pet_mailaddrver_code,
                          MAX(new_pet_ssn_CODE) AS new_pet_ssn_CODE,
                          MAX(mod_pet_ssn_CODE) AS mod_pet_ssn_CODE,
                          MAX(compt_pet_ssn_code) AS compt_pet_ssn_code,
                          MAX(cpncpaddrnotsame_code) AS cpncpaddrnotsame_code,
                          MAX(new_pet_ivdclient_code) AS new_pet_ivdclient_code,
                          MAX(mod_pet_ivdclient_code) AS mod_pet_ivdclient_code,
                          MAX(compt_pet_ivdclient_code) AS compt_pet_ivdclient_code,
                          MAX(new_pet_ncpexclude_CODE) AS new_pet_ncpexclude_CODE,
                          MAX(mod_pet_ncpexclude_CODE) AS mod_pet_ncpexclude_CODE,
                          MAX(compt_pet_ncpexclude_CODE) AS compt_pet_ncpexclude_CODE,
                          MAX(curr_ord_revw_eligible_code) AS curr_ord_revw_eligible_code,
                          MAX(petitiontoaddchild_code) AS petitiontoaddchild_code,
                          MAX(mod_pet_ncpreleasedate_CODE) AS mod_pet_ncpreleasedate_CODE,
                          MAX(compt_pet_ncpreleasedate_CODE) AS compt_pet_ncpreleasedate_CODE,
                          MAX(release_date) AS release_date,
                          MAX(new_pet_ncpnocapias_CODE) AS new_pet_ncpnocapias_CODE,
                          MAX(mod_pet_ncpnocapias_CODE) AS mod_pet_ncpnocapias_CODE,
                          MAX(compt_pet_ncpnocapias_CODE) AS compt_pet_ncpnocapias_CODE,
                          MAX(mod_pet_ncpnotbkrpt_CODE) AS mod_pet_ncpnotbkrpt_CODE,
                          MAX(compt_pet_ncpnotbkrpt_CODE) AS compt_pet_ncpnotbkrpt_CODE,
                          MAX(ChldExcludetanfCase_CODE) AS ChldExcludetanfCase_CODE,
                          MAX(Iwoissue_DATE) AS Iwoissue_DATE,
                          MAX(mod_pet_iwo_CODE) AS mod_pet_iwo_CODE,
                          MAX(compt_pet_iwo_CODE) AS compt_pet_iwo_CODE
                     FROM (SELECT CASE
                                   WHEN Reasonstatus_CODE IN ('PE', 'PF', 'LD')
                                        AND c.ncplkcaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_lkcAddrver_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND c.ncplkcaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_lkcaddrver_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND c.ncplkcaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_lkcaddrver_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PE', 'PF', 'LD')
                                        AND c.cpmailaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_mailaddrver_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND c.cpmailaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_mailaddrver_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND c.cpmailaddrver_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_mailaddrver_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PE', 'PF', 'LD')
                                        AND c.memberssn_count = c.member_count
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_ssn_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND c.memberssn_count = c.member_count
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ssn_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND c.memberssn_count = c.member_count
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ssn_code,
                                  CASE
                                   WHEN addr_match_count = 0
                                    THEN 'X'
                                   ELSE ''
                                  END cpncpaddrnotsame_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PE', 'PF', 'LD')
                                        AND ivdcase_count = 1
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_ivdclient_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND ivdcase_count = 1
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ivdclient_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND ivdcase_count = 1
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ivdclient_code,
                                  CASE
                                   WHEN   c.nsupinactiverespondent_count != 1 and @Ac_ActivityMajor_CODE='ESTP'
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_ncpexclude_CODE,
                                  CASE
                                   WHEN  c.inactiverespondent_count != 1 and @Ac_ActivityMajor_CODE='MAPP'
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ncpexclude_CODE,
                                  CASE
                                   WHEN  c.inactiverespondent_count = 1 and @Ac_ActivityMajor_CODE='MAPP'
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ncpexclude_CODE,
                                  CASE
                                   WHEN ordereff_date >= 30
                                    THEN 'X'
                                   ELSE ''
                                  END curr_ord_revw_eligible_code,
                                  c.petitiontoaddchild_code,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND incarceration_count !=1 
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ncpreleasedate_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND incarceration_count !=1 
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ncpreleasedate_CODE,
                                  release_date,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PE', 'PF', 'LD')
                                        AND statusenforce_code != 'WCAP'
                                    THEN 'X'
                                   ELSE ''
                                  END new_pet_ncpnocapias_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND statusenforce_code != 'WCAP'
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ncpnocapias_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND statusenforce_code != 'WCAP'
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ncpnocapias_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND currbankruptcy_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_ncpnotbkrpt_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND currbankruptcy_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_ncpnotbkrpt_CODE,
                                  CASE
                                   WHEN excludechildintanf_count > 0
                                    THEN 'X'
                                   ELSE ''
                                  END ChldExcludetanfCase_CODE,
                                  iwoissue_date,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PM', 'PT')
                                        AND iwoissue_date != @Ld_Low_DATE
                                    THEN 'X'
                                   ELSE ''
                                  END mod_pet_iwo_CODE,
                                  CASE
                                   WHEN Reasonstatus_CODE IN ('PS')
                                        AND  iwoissue_date != @Ld_Low_DATE
                                    THEN 'X'
                                   ELSE ''
                                  END compt_pet_iwo_CODE
                             FROM (SELECT @Ac_ReasonStatus_CODE AS Reasonstatus_CODE,
                                          ISNULL(-- Petitioner's confirmed good mailing address  
                                          (SELECT COUNT(1)
                                             FROM AHIS_Y1 e
                                            WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
                                              AND e.Status_CODE = @Lc_Status_CODE
                                              AND e.TypeAddress_CODE = 'M'
                                              AND @Ad_Run_DATE BETWEEN e.begin_date AND e.end_date), 0) AS cpmailaddrver_count,
                                          ISNULL(-- Respondents last known court address or any other address 
                                            (SELECT COUNT(1)
                                             FROM AHIS_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND f.MemberMci_IDNO = @An_Otherparty_IDNO
                                              AND f.CaseRelationship_code IN (@Lc_CaseRelationshipNCP_CODE, @Lc_CaseRelationshipPF_CODE)
                                              AND f.caseMemberStatus_CODE = 'A'
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO -- change as input @An_Otherparty_IDNO  
                                              AND e.Status_CODE = @Lc_Status_CODE
                                              AND @Ad_Run_DATE BETWEEN e.begin_date AND e.end_date), 0) AS ncplkcaddrver_count,
                                          ISNULL(-- All Members on the petition has ssn  
                                          (SELECT COUNT(1)
                                             FROM DEMO_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO
                                              AND f.CaseMemberstatus_CODE = @Lc_MemberStatusActive_CODE
                                              AND e.MemberSsn_NUMB <> 0
                                              AND e.MemberSsn_NUMB IS NOT NULL), 0) AS memberssn_count,
                                          ISNULL(-- No Of active Members on the petition   
                                          (SELECT COUNT(1)
                                             FROM DEMO_Y1 e,
                                                  CMEM_Y1 f
                                            WHERE f.Case_IDNO = @An_Case_IDNO
                                              AND e.MemberMci_IDNO = f.MemberMci_IDNO
                                              AND f.CaseMemberstatus_CODE = @Lc_MemberStatusActive_CODE), 0) AS member_count,
                                          -- 28 parties not at same address
                                          ISNULL((SELECT COUNT(1)
													FROM (SELECT  e.Attn_ADDR,
																  e.Line1_ADDR,
																  e.Line2_ADDR,
																  e.City_ADDR,
																  e.State_ADDR,
																  e.Zip_ADDR,
																  e.Country_ADDR
															 FROM AHIS_Y1 e
															WHERE e.MemberMci_IDNO = @An_CpMemberMci_IDNO
															  AND e.Status_CODE = @Lc_Status_CODE
															  AND e.TypeAddress_CODE = @Lc_MailingTypeAddress_CODE
															  AND @Ad_Run_DATE BETWEEN e.Begin_DATE AND e.End_DATE ) e,
														  (SELECT a.Attn_ADDR,
																  a.Line1_ADDR,
																  a.Line2_ADDR,
																  a.City_ADDR,
																  a.State_ADDR,
																  a.Zip_ADDR,
																  a.Country_ADDR
															 FROM CMEM_Y1 c
																  JOIN AHIS_Y1 a 
																  ON a.MemberMci_IDNO = c.MemberMci_IDNO
																  AND a.Status_CODE = @Lc_Status_CODE
																  AND a.TypeAddress_CODE = @Lc_MailingTypeAddress_CODE
																  AND @Ad_Run_DATE BETWEEN a.Begin_DATE AND a.End_DATE
															WHERE c.Case_IDNO = @An_Case_IDNO
															  AND c.MemberMci_IDNO = @An_Otherparty_IDNO -- change as input @An_Otherparty_IDNO  
															  AND c.CaseRelationship_code IN (@Lc_CaseRelationshipPF_CODE, @Lc_CaseRelationshipNCP_CODE)
															  AND c.CaseMemberStatus_CODE = @Lc_MemberStatusActive_CODE) d 
													WHERE e.Line1_ADDR = d.Line1_ADDR
													  AND e.line2_addr = d.Line2_ADDR
													  AND e.City_ADDR = d.City_ADDR
													  AND e.State_ADDR = d.State_ADDR
													  AND e.Zip_ADDR = d.Zip_ADDR
													  AND e.country_ADDR = d.country_ADDR), 0) AS addr_match_count,
                                          -- 33 respondent not excluded by genetic test
                                          
                                          ISNULL((SELECT COUNT(1)
                                                     FROM DMJR_y1 d 
													    WHERE ActivityMajor_CODE=@Ac_ActivityMajor_CODE
													      AND MajorIntSeq_NUMB =@An_MajorIntSeq_NUMB 
													      AND OthpSource_IDNO IN(SELECT MemberMci_IDNO 
																					FROM CMEM_Y1 b
																				      WHERE b.Case_IDNO =@An_Case_IDNO
																					 AND b.MemberMci_IDNO =@An_Otherparty_IDNO -- change as input @An_Otherparty_IDNO 
																					 AND b.CaseRelationship_CODE IN('A', 'P')
																					 AND b.CaseMemberstatus_CODE = 'I'
																					 AND ReasonMemberStatus_CODE = 'X'
																					 AND d.Case_IDNO=b.Case_IDNO )),0)AS nsupinactiverespondent_count,
											ISNULL((SELECT COUNT(1)
										            FROM Dmjr_y1 
										             WHERE ActivityMajor_CODE=@Ac_ActivityMajor_CODE
										               AND TypeReference_CODE='PT'
										               AND Case_IDNO=@An_Case_IDNO
										               AND MemberMci_IDNO=@An_Otherparty_IDNO-- change as input @An_Otherparty_IDNO
										               AND MajorIntSeq_NUMB =@An_MajorIntSeq_NUMB ),0)AS inactiverespondent_count, 	                            
                                         
                                          -- 29 Petitioner is IV-D Client
                                          ISNULL((SELECT COUNT(1)
                                                    FROM CASE_Y1 c
                                                   WHERE c.Case_IDNO = @An_Case_IDNO
                                                     AND c.Statuscase_CODE = @Lc_StatusCaseOpen_CODE
                                                     AND c.Typecase_CODE != 'H'), 0) AS ivdcase_count,
                                                     
                                          -- 19, 20 Order is atleast 2 1/2 years old
                                          (SELECT DATEDIFF(mm,OrderIssued_DATE,@Ad_Run_DATE)
                                              FROM SORD_Y1 s
                                            WHERE s.Case_IDNO = @An_Case_IDNO
                                              AND s.EndValidity_DATE = @Ld_High_DATE) AS OrderEff_DATE,
                                          
                                          -- 26 checkbox for adding child to order with paternity not established
                                          (CASE
                                            WHEN @Ac_ActivityMajor_CODE = 'ESTP'
                                             THEN 'X'
                                            ELSE ''
                                           END) AS petitiontoaddchild_code,
                                          -- 35 respondent no longer incarcerated
                                          ISNULL((SELECT COUNT(1)
                                                    FROM MDET_Y1 m
                                                   WHERE m.MemberMci_IDNO = @An_Otherparty_IDNO -- change as input @An_Otherparty_IDNO  
                                                      AND ((m.Institutionalized_DATE != @Ld_Low_DATE
                                                           OR m.Incarceration_DATE != @Ld_Low_DATE) 
                                                          AND (dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME() < Release_DATE
                                                                or Release_DATE = @Ld_High_DATE))
                                                       AND Endvalidity_DATE = @Ld_High_DATE), 0) AS incarceration_count,
                                                   
                                          -- 35 Release date
                                            (SELECT 
													ISNULL(CASE
                                                    WHEN Release_DATE in(@Ld_High_DATE, @Ld_Low_DATE)
                                                    THEN NULL
                                                   ELSE CAST(Release_DATE AS VARCHAR(10))
                                                   END, '')
                                                  
                                             FROM MDET_Y1 n
                                            WHERE n.MemberMci_IDNO =@An_Otherparty_IDNO-- change as input @An_Otherparty_IDNO  
                                                       AND ((n.Institutionalized_DATE != @Ld_Low_DATE
                                                             OR n.Incarceration_DATE != @Ld_Low_DATE) 
                                                          AND (  Release_DATE >= @Ad_Run_DATE
                                                                or Release_DATE = @Ld_High_DATE))
                                                           AND Endvalidity_DATE = @Ld_High_DATE)AS Release_DATE,
                                          
                                          c.StatusEnforce_CODE,
                                          -- 38 no bankruptcy 
                                          ISNULL((SELECT COUNT(*)
                                                    FROM BNKR_Y1 b
                                                   WHERE (b.TypeBankruptcy_CODE = @Lc_BankruptcyType13_CODE
                                                       OR (b.TypeBankruptcy_CODE <> @Lc_BankruptcyType13_CODE
                                                           AND ((b.Dismissed_DATE != @Ld_Low_DATE
                                                                 AND @Ad_Run_DATE > Dismissed_DATE)
                                                                 OR (b.Discharge_DATE != @Ld_Low_DATE
                                                                     AND @Ad_Run_DATE > Discharge_DATE))))), 0) AS currbankruptcy_count,
                                          -- 39 excluded child on tanf case
                                          ISNULL((SELECT COUNT(1)
                                                    FROM CASE_Y1 c,
                                                         CMEM_Y1 m
                                                   WHERE c.Case_IDNO = @An_Case_IDNO
                                                     AND c.Case_IDNO = m.Case_IDNO
                                                     AND m.CaseRelationship_code = @Lc_CaseRelationshipDP_CODE
                                                     AND m.CaseMemberstatus_CODE = 'A'  
                                                     AND c.Typecase_CODE = 'A'
                                                     AND c.StatusCase_CODE = @Lc_StatusCaseOpen_CODE
                                                     AND EXISTS (SELECT 1
                                                                   FROM GTST_Y1 g
                                                                  WHERE g.Case_IDNO = @An_Case_IDNO
                                                                    AND g.MemberMci_IDNO = m.MemberMci_IDNO
                                                                    AND g.TestResult_CODE = 'X'
                                                                    AND g.EndValidity_DATE =  @Ld_High_DATE
                                                                    AND g.Schedule_NUMB IN (SELECT Schedule_NUMB
                                                                                            FROM DMNR_Y1 d
                                                                                           WHERE d.Case_IDNO = @An_Case_IDNO
                                                                                             AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB
                                                                                             AND d.Schedule_NUMB != 0))), 0) AS excludechildintanf_count,
                                          -- 40 Date of last IWO issued
                                          (SELECT ISNULL(MAX(Generate_dttm), @Ld_Low_DATE )
                                             FROM NRRQ_Y1 n
                                            WHERE n.Notice_ID = @Lc_Notice_ID
                                              AND n.Recipient_CODE = 'SI' 
                                              AND n.Case_IDNO = @An_Case_IDNO ) AS iwoissue_date--, 
                                    
                                     FROM --DMNR_Y1 a, 
                                  CASE_Y1 c
                                    WHERE c.Case_IDNO = @An_Case_IDNO
                                          AND c.Statuscase_code = @Lc_StatusCaseOpen_CODE
                                  )c)t) K) up UNPIVOT (Element_VALUE FOR Element_NAME IN ( new_pet_lkcAddrver_CODE, mod_pet_lkcaddrver_code, compt_pet_lkcaddrver_code, new_pet_mailaddrver_code, mod_pet_mailaddrver_code, compt_pet_mailaddrver_code, new_pet_ssn_CODE, mod_pet_ssn_CODE, compt_pet_ssn_code, cpncpaddrnotsame_code, new_pet_ivdclient_code, mod_pet_ivdclient_code, compt_pet_ivdclient_code, new_pet_ncpexclude_CODE, mod_pet_ncpexclude_CODE, compt_pet_ncpexclude_CODE, curr_ord_revw_eligible_code, petitiontoaddchild_code, mod_pet_ncpreleasedate_CODE, compt_pet_ncpreleasedate_CODE, release_date, new_pet_ncpnocapias_CODE, mod_pet_ncpnocapias_CODE, compt_pet_ncpnocapias_CODE, mod_pet_ncpnotbkrpt_CODE, compt_pet_ncpnotbkrpt_CODE, ChldExcludetanfCase_CODE, Iwoissue_DATE, mod_pet_iwo_CODE, compt_pet_iwo_CODE )) AS pvt);

   SET @Ac_MSG_CODE = @Lc_StatusSuccess_CODE;
  END TRY

  BEGIN CATCH
   SELECT @Ac_Msg_CODE = @Lc_StatusFailed_CODE,
          @Ln_Error_NUMB = ERROR_NUMBER(),
          @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF ERROR_NUMBER () <> 50001
    BEGIN
     SET @Ls_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @Ls_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT OUTPUT;

   SET @As_DescriptionError_TEXT = @Ls_DescriptionError_TEXT;
  END CATCH
 END


GO
