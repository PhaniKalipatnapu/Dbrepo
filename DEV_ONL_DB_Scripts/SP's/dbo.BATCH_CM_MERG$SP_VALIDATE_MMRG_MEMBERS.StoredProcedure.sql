/****** Object:  StoredProcedure [dbo].[BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS
Programmer Name	:	IMP Team.
Description		:	The purpose of this procedure is to validate members before accept the merge request
                     and before process merge request. 
                     
					1 - A - E1014  Must have at least one active Member DCN
					16 - R - E1025 Merging Member MCI's DOB, Gender and Name must match
					11 - K - E1025  Merging Member MCI's DOB, Gender and Name must match
					2 - B - E1015 DP and CP from the same case
					3 - C - E1016 CP and NCP/PF from the same case
					4 - D - E1017  DP and NCP/PF from the same case
					-- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
					19 - Q - E0022 Guardian and CP from the same case
					20 - U - E0023 Guardian and NCP/PF from the same case
					21 - V - E0024 Guardian and DP from the same case	
					-- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END				
					5 - E - E1018 Two Member DCN's with different Program Types
					17 - H - E1245 Two Member DCN's with mismatched count in member welfare details
					7 - G - E1021 There are open financial obligations .
					9 - I - E1030  Member DCN has an open activity chain; close it before continuing
					10 - J - E1019  Only one open verified address of the same address type allowed
					18 - T - E1243  Employer Overlap
					12 - P - E1026  Member DCN's Paternity Status does not match
					13 - M - E1027 Primary Member A already exists as a Secondary Member
					14 - N - E1028 Secondary Member already exists as a Primary or Secondary Member
					15 - O - E1029  Merge request is already pending.
					
Frequency		:	DAILY
Developed On	:	5/3/2012
Called By		:	BATCH_CM_MERG$SP_PROCESS_MEMBER_MERGE
Called On		:	
--------------------------------------------------------------------------------------------------------------------
Modified By		:	
Modified On		:	
Version No		:	1.0
--------------------------------------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS]
 @An_MemberMciPrimary_IDNO   NUMERIC(10),
 @An_MemberMciSecondary_IDNO NUMERIC(10),
 @Ac_Process_ID              CHAR(10),
 @Ad_Run_DATE                DATETIME,
 @Ac_Msg_CODE                VARCHAR(5) OUTPUT,
 @As_DescriptionError_TEXT   VARCHAR(4000) OUTPUT
AS
 BEGIN
  DECLARE @Li_Zero_NUMB						 SMALLINT		= 0,							 
          @Lc_Yes_CODE                       CHAR(1)		= 'Y',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1)		= 'A',
          @Lc_VerificationStatusGood_CODE    CHAR(1)		= 'Y',
          @Lc_VerificationStatusPending_CODE CHAR(1)		= 'P',
          @Lc_CaseRelationshipCP_CODE        CHAR(1)		= 'C',
          @Lc_CaseRelationshipPF_CODE        CHAR(1)		= 'P',
          @Lc_CaseRelationshipNCP_CODE       CHAR(1)		= 'A',
          @Lc_CaseRelationshipDEP_CODE       CHAR(1)		= 'D',
          -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
          @Lc_CaseRelationshipGuardian_CODE  CHAR(1)		= 'G',
          -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END
          @Lc_TypeAddressC_CODE				 CHAR(1)		= 'C',
          @Lc_Space_TEXT                     CHAR(1)		= ' ',
          @Lc_StatusFailed_CODE				 CHAR(1)		= 'F',
          @Lc_StatusMergePending_CODE        CHAR(1)		= 'P',
          @Ls_Procedure_NAME                 VARCHAR(60)	= 'BATCH_CM_MERG$SP_VALIDATE_MMRG_MEMBERS',
          @Ld_Low_DATE                       DATE			= '01/01/0001',
          @Ld_High_DATE						 DATE			= '12/31/9999';
          
  DECLARE @Ls_FetchStatus_BIT                SMALLINT,
          @Ls_MhisFetchStatus_BIT            SMALLINT,
          @Ln_Count                          NUMERIC(9)		= 0,
          @Ln_MhisExists_COUNT               NUMERIC(9)		= 0,
          @Ln_MhisPrimary_COUNT              NUMERIC(9)		= 0,
          @Ln_MhisSecondary_COUNT            NUMERIC(9)		= 0,
          @Ln_AhisConfirmedCnt_NUMB          NUMERIC(9)		= 0,
          @Ln_EhisConfirmed_NUMB             NUMERIC(9)		= 0,
          @Ln_Error_NUMB					 NUMERIC(11),
          @Ln_ErrorLine_NUMB				 NUMERIC(11),
          @Lc_Status_CODE                    CHAR(1)		= '',
          @Ls_Sql_TEXT                       VARCHAR(100),
          @Ls_Sqldata_TEXT                   VARCHAR(4000);
          
  DECLARE @Cmem_CUR							 CURSOR,
          @i$Case_IDNO                       NUMERIC(10)	= 0,
          @Mhis_CUR							 CURSOR,
          @iMhis$MemberMci_IDNO              NUMERIC(10),
          @iMhis$Case_IDNO                   NUMERIC(10),
          @iMhis$TypeWelfare_CODE            CHAR(1),
          @iMhis$CaseWelfare_IDNO            NUMERIC(10),
          @iMhis$WelfareMemberMci_IDNO       NUMERIC(10),
          @iMhis$Start_DATE                  DATE,
          @iMhis$End_DATE                    DATE;
          
          

  BEGIN TRY
   SET @Ac_Msg_CODE = NULL;
   SET @As_DescriptionError_TEXT = NULL;
   SET @Ls_Sql_TEXT = 'VALIDATE MEMBERS';
   SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + 'MemberMciSecondary_IDNO' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (10)), '');
   /*
     1. Check atleast one member is active
     A - E1014  Must have at least one active Member DCN
         */
   SET @Ls_Sql_TEXT = 'SELECT DEMO_CMEM';

   SELECT @Ln_Count = COUNT(1)
     FROM DEMO_Y1 a,
          CMEM_Y1 cm
    WHERE a.MemberMci_IDNO IN (@An_MemberMciPrimary_IDNO, @An_MemberMciSecondary_IDNO)
      AND a.MemberMci_IDNO = cm.MemberMci_IDNO
      AND cm.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;

   IF @Ln_Count = 0
    BEGIN
     SET @Ac_Msg_CODE = 'A';
     SET @As_DescriptionError_TEXT = 'BOTH THE MEMBERS WERE INACTIVE';

     RETURN;
    END

   /* 16. To check genders of both DCN'S
         R - E1365 Member genders do not match */
   SET @Ls_Sql_TEXT = 'SELECT DEMO_CMEM';

   SELECT @Ln_Count = COUNT(1)
     FROM DEMO_Y1 dmp,
          DEMO_Y1 dms
    WHERE dmp.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND dms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND dmp.MemberSex_CODE != dms.MemberSex_CODE;

   IF @Ln_Count > 0
    BEGIN
     SET @Ac_Msg_CODE = 'R';
     SET @As_DescriptionError_TEXT = 'MEMEBERS GENDER DONOT MATCH';

     RETURN;
    END

  

   /*
    11. Member DCN's SSN, DOB and Name must match
    K - E1025  Merging Member MCI's DOB, Gender and Name must match
        */
   SELECT @Ln_Count = COUNT(1)
     FROM DEMO_Y1 dmp,
          DEMO_Y1 dms
    WHERE dmp.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND dms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      -- condition to allow merge if secondary member DOB is blank
      AND ((dms.Birth_DATE NOT IN (@Ld_High_DATE, @Ld_Low_DATE)
            AND dmp.Birth_DATE = dms.Birth_DATE)
            OR (dms.Birth_DATE IN (@Ld_High_DATE, @Ld_Low_DATE)))
      AND dmp.Last_NAME = dms.Last_NAME
      AND dmp.First_NAME = dms.First_NAME
      --Condition added to validate Middle name
      AND dmp.Middle_NAME = dms.Middle_NAME;

   IF @Ln_Count = 0
    BEGIN
     SET @Ac_Msg_CODE = 'K';
     SET @As_DescriptionError_TEXT = ' MEMEBERS Last_NAME, First_NAME, Birth_DATE, Individual_IDNO DONOT MATCH';

     RETURN;
    END
   --------------------------------------------------------------------------------
   -- Both members should have same relation in the same case
   --------------------------------------------------------------------------------				
   SET @Ls_Sql_TEXT = 'SLECT CMEM_MEM_RELATION';

   SELECT TOP 1 @Lc_Status_CODE = CASE
                                   /*
                                    2. Cannot merge a DP and CP belonging to the same case.
                                    B - E1015 - The merging MCI numbers must not be assigned to a DP and CP from the same case
                                    */
                                   WHEN (pr.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
                                         AND se.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE)
                                         OR (pr.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE
                                             AND se.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE)
                                    THEN 'B'
                                   /*
                                   3.Cannot merge a CP and NCP/PF from the same case
                                   C - E1016 - The merging MCI numbers must not be assigned to a CP and NCP/PF from the same case
                                   */
                                   WHEN (pr.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE
                                         AND (se.CaseRelationship_CODE = @Lc_CaseRelationshipPF_CODE
                                               OR se.CaseRelationship_CODE = @Lc_CaseRelationshipNCP_CODE))
                                         OR ((pr.CaseRelationship_CODE = @Lc_CaseRelationshipPF_CODE
                                               OR pr.CaseRelationship_CODE = @Lc_CaseRelationshipNCP_CODE)
                                             AND se.CaseRelationship_CODE = @Lc_CaseRelationshipCP_CODE)
                                    THEN 'C'
                                   /*
                                    4. Cannot merge a NCP/PF and DP belonging to the same case.
                                    D - E1017  DP and NCP/PF from the same case
                                    */
                                   WHEN (pr.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE
                                         AND (se.CaseRelationship_CODE = @Lc_CaseRelationshipPF_CODE
                                               OR se.CaseRelationship_CODE = @Lc_CaseRelationshipNCP_CODE))
                                         OR ((pr.CaseRelationship_CODE = @Lc_CaseRelationshipPF_CODE
                                               OR pr.CaseRelationship_CODE = @Lc_CaseRelationshipNCP_CODE)
                                             AND se.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE)
                                    THEN 'D'
                                    -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
                                    /*
                                    19. The merging MCI Numbers must not be assigned to a Guardian and CP from the same case
                                    Q - E0022 Guardian and CP from the same case
                                    */
                                   WHEN @Lc_CaseRelationshipCP_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
											AND @Lc_CaseRelationshipGuardian_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
										THEN 'Q'
                                    /*
                                    20. The merging MCI numbers must not be assigned to a Guardian and NCP/PF from the same case
                                    U - E0023 Guardian and NCP/PF from the same case
                                    */
                                   WHEN @Lc_CaseRelationshipGuardian_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
											AND (@Lc_CaseRelationshipNCP_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
												OR @Lc_CaseRelationshipPF_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE))
										THEN 'U'
                                    /*
                                    21. The merging MCI Numbers must not be assigned to a Guardian and DP from the same case
                                    V - E0024 Guardian and DP from the same case
                                    */
                                   WHEN @Lc_CaseRelationshipDEP_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
											AND @Lc_CaseRelationshipGuardian_CODE IN (pr.CaseRelationship_CODE, se.CaseRelationship_CODE)
										THEN 'V'
                                    -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END
                                  END
     FROM CMEM_Y1 pr,
          CMEM_Y1 se
    WHERE pr.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND se.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND pr.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND se.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
      AND pr.CaseRelationship_CODE <> se.CaseRelationship_CODE
      AND pr.Case_IDNO = se.Case_IDNO;
      
	-- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - START
   IF ISNULL(@Lc_Status_CODE,'') <> ''
    BEGIN
     SET @Ac_Msg_CODE = @Lc_Status_CODE;
     SET @As_DescriptionError_TEXT = 'MEMEBERS RELATION DONOT MATCH';
     RETURN;
    END
    -- 13172 - MERG - CR0350 Prevent Merge of Guardian with Case Members 20140116 - END

   /*
   5. Cannot merge two Members with a different Program Type (MHIS)
   E - E1018 Two Member DCN's with different Program Types
   */
   SET @Ls_Sql_TEXT = 'SLECT MHIS_MHIS';

   SELECT @Ln_Count = COUNT(1)
     FROM MHIS_Y1 pr,
          MHIS_Y1 sc
    WHERE pr.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND sc.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND CASE
           WHEN pr.TypeWelfare_CODE = 'A'
            THEN 'A'
           ELSE 'N'
          END <> CASE
                  WHEN sc.TypeWelfare_CODE = 'A'
                   THEN 'A'
                  ELSE 'N'
                 END
      AND @Ad_Run_DATE BETWEEN pr.Start_DATE AND pr.End_DATE
      AND @Ad_Run_DATE BETWEEN sc.Start_DATE AND sc.End_DATE
      /*Exclude NCP/PF Cases for MHIS validations*/
      AND NOT EXISTS (SELECT 1 FROM CMEM_Y1 b WHERE b.Case_IDNO = pr.Case_IDNO AND b.MemberMci_IDNO = pr.MemberMci_IDNO AND b.CaseRelationship_CODE IN('A','P') AND b.CaseMemberStatus_CODE = 'A')
      /*Exclude NCP/PF Cases for MHIS validations*/
      AND NOT EXISTS (SELECT 1 FROM CMEM_Y1 c WHERE c.Case_IDNO = sc.Case_IDNO AND c.MemberMci_IDNO = sc.MemberMci_IDNO AND c.CaseRelationship_CODE IN('A','P') AND c.CaseMemberStatus_CODE = 'A');

   IF @Ln_Count > 0
    BEGIN
     SET @Ac_Msg_CODE = 'E';
     SET @As_DescriptionError_TEXT = 'MEMEBERS MHIS PROGRAM TYPE DONOT MATCH';

     RETURN;
    END

   --------------------------------------------------------------------------------
   -- Both members should have same mhis history. if they are in the same case
   --------------------------------------------------------------------------------
   /*
   5. Both members should have same mhis history. if they are in the same case
   E - E1018 Two Member DCN's with different Program Types
   
   18. Both members should have same mhis history. if they are in the same case
   H - E1245 Member Welfare details mismatch in count
   */
   SET @Ls_Sql_TEXT = 'MHIS MMERG VALIDATIONS';
   SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (9)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (9)), '');
   -- Defining the cursor @Cmem_CUR
   SET @Cmem_CUR = CURSOR LOCAL FORWARD_ONLY STATIC
   FOR SELECT a.Case_IDNO
         FROM CMEM_Y1 a,
              CMEM_Y1 b
        WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
          AND b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
          AND a.Case_IDNO = b.Case_IDNO
           /*Exclude NCP/PF Cases for MHIS validations*/
          AND a.CaseRelationship_CODE NOT IN ('A','P')
          /*Exclude NCP/PF Cases for MHIS validations*/
          AND b.CaseRelationship_CODE NOT IN ('A','P');
          
   SET @Ls_Sql_TEXT = 'OPEN @Cmem_CUR';

   OPEN @Cmem_CUR;

   SET @Ls_Sql_TEXT = 'FETCH @Cmem_CUR - 1';

   FETCH NEXT FROM @Cmem_CUR INTO @i$Case_IDNO;

   SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;

   -- cursor loop1 Starts @Cmem_CUR		
   WHILE @Ls_FetchStatus_BIT = 0
    BEGIN
     SET @Ls_Sql_TEXT = 'MHIS MMERG VALIDATIONS LOOP';
     SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (9)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (9)), '') + 'Case_IDNO' + ISNULL (CAST (@i$Case_IDNO AS VARCHAR (6)), '');
     -- Defining the cursor @@Mhis_CUR
     SET @Mhis_CUR = CURSOR LOCAL FORWARD_ONLY STATIC
     FOR SELECT MemberMci_IDNO,
                Case_IDNO,
                Start_DATE,
                End_DATE,
                TypeWelfare_CODE,
                CaseWelfare_IDNO,
                WelfareMemberMci_IDNO
           FROM MHIS_Y1
          WHERE Case_IDNO = @i$Case_IDNO
            AND MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

     SELECT @Ln_MhisSecondary_COUNT = COUNT(1)
       FROM MHIS_Y1 m
      WHERE m.Case_IDNO = @i$Case_IDNO
        AND m.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;

     SELECT @Ln_MhisPrimary_COUNT = COUNT(1)
       FROM MHIS_Y1 m
      WHERE m.Case_IDNO = @i$Case_IDNO
        AND m.MemberMci_IDNO = @An_MemberMciPrimary_IDNO;

     IF @Ln_MhisSecondary_COUNT <> @Ln_MhisPrimary_COUNT
      BEGIN
       SET @Ls_Sqldata_TEXT = 'PROCESS ID: ' + @Ac_Process_ID + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
       SET @Ls_Sql_TEXT = 'MEMBER WELFARE DETAILS MISMATCH IN COUNT';
       SET @Ac_Msg_CODE = 'H';
       SET @As_DescriptionError_TEXT = @Ls_Sqldata_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT;
      END

     SET @Ls_Sql_TEXT = 'OPEN @Mhis_CUR';

     OPEN @Mhis_CUR;

     SET @Ls_Sql_TEXT = 'FETCH @Mhis_CUR - 1';

     FETCH NEXT FROM @Mhis_CUR INTO @iMhis$MemberMci_IDNO, @iMhis$Case_IDNO, @iMhis$Start_DATE, @iMhis$End_DATE, @iMhis$TypeWelfare_CODE, @iMhis$CaseWelfare_IDNO, @iMhis$WelfareMemberMci_IDNO;

     SELECT @Ls_MhisFetchStatus_BIT = @@FETCH_STATUS;

     -- cursor loop1 Starts @Mhis_CUR		
     WHILE @Ls_MhisFetchStatus_BIT = 0
      BEGIN
       SELECT @Ln_MhisExists_COUNT = COUNT(1)
         FROM MHIS_Y1
        WHERE Case_IDNO = @iMhis$Case_IDNO
          AND MemberMci_IDNO = @An_MemberMciPrimary_IDNO
          AND Start_DATE = @iMhis$Start_DATE
          AND End_DATE = @iMhis$End_DATE
          AND TypeWelfare_CODE = @iMhis$TypeWelfare_CODE
          AND CaseWelfare_IDNO = @iMhis$CaseWelfare_IDNO
          AND WelfareMemberMci_IDNO = @iMhis$WelfareMemberMci_IDNO;

       IF @Ln_MhisExists_COUNT = 0
        BEGIN
         SET @Ls_Sqldata_TEXT = 'PROCESS ID: ' + @Ac_Process_ID + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
         SET @Ls_Sql_TEXT = 'MEMBER HISTORY MISMATCH ON CASE';
         SET @Ac_Msg_CODE = 'E';
         SET @As_DescriptionError_TEXT = @Ls_Sqldata_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT;

         RETURN;
        END

       FETCH NEXT FROM @Mhis_CUR INTO @iMhis$MemberMci_IDNO, @iMhis$Case_IDNO, @iMhis$Start_DATE, @iMhis$End_DATE, @iMhis$TypeWelfare_CODE, @iMhis$CaseWelfare_IDNO, @iMhis$WelfareMemberMci_IDNO;

       SELECT @Ls_MhisFetchStatus_BIT = @@FETCH_STATUS;
      END

     CLOSE @Mhis_CUR;

     DEALLOCATE @Mhis_CUR;

     -- End of Second loop
     FETCH NEXT FROM @Cmem_CUR INTO @i$Case_IDNO;

     SELECT @Ls_FetchStatus_BIT = @@FETCH_STATUS;
    END

   CLOSE @Cmem_CUR;

   DEALLOCATE @Cmem_CUR;

   --- End of Frist loop
   /*
     7. Cannot merge if the secondary member has any open
     financial obligations.
     G - E1021 There are open financial obligations
      */
   SET @Ls_Sql_TEXT = 'SELECT OBLE';

   -- To verify if the secondary DCN has a associated open obligation
   SELECT TOP 1 @Ln_Count = COUNT(1)
     FROM OBLE_Y1 os
    WHERE os.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND os.EndValidity_DATE = @Ld_High_DATE
      AND (@Ad_Run_DATE BETWEEN os.BeginObligation_DATE AND os.EndObligation_DATE
           OR os.ExpectToPay_AMNT > @Li_Zero_NUMB)

   IF @Ln_Count > 0
    BEGIN
     SET @Ac_Msg_CODE = 'G';
     SET @As_DescriptionError_TEXT = 'SECONDARY MEMBER HAS AN OPEN/CLOSED OBLIGATION';

     RETURN;
    END

   /*
    9. Member DCN must not have an open activity chain
    I- E1023 Merging member MCIs must not have an open activity chain
   */
   SET @Ls_Sql_TEXT = 'SLECT DMJR_CMEM';

   --Secondary member and it relations should not have any open activity
   SELECT TOP 1 @Ln_Count = COUNT(1)
     FROM DMJR_Y1 dmp,
          CMEM_Y1 b
    WHERE b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND b.Case_IDNO = dmp.Case_IDNO
        AND ((b.CaseRelationship_CODE IN (@Lc_CaseRelationshipPF_CODE,@Lc_CaseRelationshipNCP_CODE))
		OR (b.CaseRelationship_CODE IN (@Lc_CaseRelationshipCP_CODE) AND (OthpSource_IDNO = b.MemberMci_IDNO OR Reference_ID = CAST(b.MemberMci_IDNO AS VARCHAR))))
      AND dmp.Status_CODE = 'STRT'
      AND dmp.ActivityMajor_CODE != 'CASE';

   IF @Ln_Count > 0
    BEGIN
     SET @Ac_Msg_CODE = 'I';
     SET @As_DescriptionError_TEXT = 'SECONDARY MEMBER HAS AN OPEN ACTIVITY';

     RETURN;
    END

   ---------------------------------------------------
   --  AHIS
   ---------------------------------------------------
   /*
   10. Member DCN must have only one open verified address of the same address type
   J - E1019  Only one open verified address of the same address type allowed
   */
   SET @Ls_Sql_TEXT = 'SLECT AHIS_Y1';

   SELECT @Ln_Count = MAX(Count_QNTY)
     FROM (SELECT TypeAddress_CODE,
                  COUNT (*) Count_QNTY
             FROM AHIS_Y1
            WHERE @Ad_Run_DATE BETWEEN Begin_DATE AND End_DATE
              AND Status_CODE = @Lc_VerificationStatusGood_CODE
              AND TypeAddress_CODE != @Lc_TypeAddressC_CODE
              AND MemberMci_IDNO IN (@An_MemberMciPrimary_IDNO, @An_MemberMciSecondary_IDNO)
            GROUP BY TypeAddress_CODE)s;

   IF @Ln_Count > 1
    BEGIN
     SET @Ac_Msg_CODE = 'J';
     SET @As_DescriptionError_TEXT = 'MORE THAN ONE VERIFIED ADDRESS OF SAME TYPE EXISTS FOR THE MEMBERS';

     RETURN;
    END

   /*
   10. Member DCN must have only one open verified address of the same address type
   J - E1019  Only one open verified address of the same address type allowed
   */
   SET @Ls_Sql_TEXT = 'AHIS MMERG VALIDATIONS';
   SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (10)), '');

   SELECT TOP 1 @Ln_AhisConfirmedCnt_NUMB = COUNT(1)
     FROM AHIS_Y1 a,
          AHIS_Y1 b
    WHERE a.End_DATE = @Ld_High_DATE
      AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND b.End_DATE = @Ld_High_DATE
      AND b.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND b.TypeAddress_CODE = a.TypeAddress_CODE
      AND b.TypeAddress_CODE != @Lc_TypeAddressC_CODE
      AND ((a.Begin_DATE <= b.Begin_DATE
            AND a.End_DATE > b.Begin_DATE)
            OR (a.Begin_DATE < b.End_DATE
                AND a.End_DATE >= b.End_DATE)
            OR (a.Begin_DATE >= b.Begin_DATE
                AND a.End_DATE <= b.End_DATE))
    GROUP BY B.TypeAddress_CODE;

   IF @Ln_AhisConfirmedCnt_NUMB > 0
    BEGIN
     SET @Ls_Sqldata_TEXT = 'PROCESS ID: ' + @Ac_Process_ID + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
     SET @Ls_Sql_TEXT = 'AHIS - Confirmed Address OverLap ';
     SET @Ac_Msg_CODE = 'J';
     SET @As_DescriptionError_TEXT = @Ls_Sqldata_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT;

     RETURN;
    END

   ----------------------------------------------------------------------------------
   ---- EHIS
   ----------------------------------------------------------------------------------			
   /*
     18. EHIS - Multiple primary employers
     J - E1243 Employer Overlap
   */
   SET @Ls_Sql_TEXT = 'EHIS MMERG VALIDATIONS';
   SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (10)), '');

   SELECT TOP 1 @Ln_EhisConfirmed_NUMB = COUNT(1)
     FROM EHIS_Y1 a,
          EHIS_Y1 b
    WHERE a.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND a.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.EmployerPrime_INDC = @Lc_Yes_CODE
      AND ((a.BeginEmployment_DATE <= b.BeginEmployment_DATE
            AND a.EndEmployment_DATE > b.BeginEmployment_DATE)
            OR (a.BeginEmployment_DATE < b.EndEmployment_DATE
                AND a.EndEmployment_DATE >= b.EndEmployment_DATE)
            OR (a.BeginEmployment_DATE >= b.BeginEmployment_DATE
                AND a.EndEmployment_DATE <= b.EndEmployment_DATE))
      AND b.EmployerPrime_INDC = a.EmployerPrime_INDC
      AND b.Status_CODE = @Lc_VerificationStatusGood_CODE
      AND a.EmployerPrime_INDC = @Lc_Yes_CODE
      AND b.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND a.EndEmployment_DATE = @Ld_High_DATE
      AND b.EndEmployment_DATE = @Ld_High_DATE;

   IF @Ln_EhisConfirmed_NUMB > 0
    BEGIN
     SET @Ls_Sqldata_TEXT = 'PROCESS ID: ' + @Ac_Process_ID + @Lc_Space_TEXT + @Ls_Sqldata_TEXT;
     SET @Ls_Sql_TEXT = 'EHIS - MULTIPLE PRIMARY EMPLOYERS ';
     SET @Ac_Msg_CODE = 'T';
     SET @As_DescriptionError_TEXT = @Ls_Sqldata_TEXT + @Lc_Space_TEXT + @Ls_Sql_TEXT;

     RETURN;
    END

   /*
   12. Member DCN's Paternity Status must match
   P - E1026  Member DCN's Paternity Status does not match
   */
   SET @Ls_Sql_TEXT = 'PATERNITY STATUS VALIDATIONS';

   SELECT TOP 1 @Ln_Count = COUNT(1)
     FROM CMEM_Y1 cmp,
          CMEM_Y1 cms
    WHERE cmp.MemberMci_IDNO = @An_MemberMciPrimary_IDNO
      AND cms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO
      AND cmp.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE
      AND cms.CaseRelationship_CODE = @Lc_CaseRelationshipDEP_CODE;

   IF @Ln_Count > 0
    BEGIN
      SELECT @Ln_Count= COUNT(1)
		   FROM MPAT_Y1 mp JOIN MPAT_Y1 ms
			 ON mp.StatusEstablish_CODE != ms.StatusEstablish_CODE
		  WHERE mp.MemberMci_IDNO = @An_MemberMciPrimary_IDNO 
			AND ms.MemberMci_IDNO = @An_MemberMciSecondary_IDNO;  

     IF @Ln_Count > 0
      BEGIN
       SET @Ac_Msg_CODE = 'P';
       SET @As_DescriptionError_TEXT = 'MEMBER PATERNITY STATUS DONOT MATCH';

       RETURN;
      END
    END

   IF @Ac_Process_ID = 'MERG'
    BEGIN
     SET @Ls_Sql_TEXT = 'INSIDE MEGR';
     SET @Ls_Sqldata_TEXT = 'MemberMciPrimary_IDNO: ' + ISNULL (CAST (@An_MemberMciPrimary_IDNO AS VARCHAR (10)), '') + ' MemberMciSecondary_IDNO: ' + ISNULL (CAST (@An_MemberMciSecondary_IDNO AS VARCHAR (10)), '');
     /*
      13. Primary Member cannot already exist in the VMMRG table as a Secondary Member
      M - E1027 Primary Member cannot exists as a Secondary Member
      */
     SET @Ls_Sql_TEXT = 'SELECT MMRG1';

     SELECT TOP 1 @Ln_Count = COUNT(1)
       FROM MMRG_Y1 mr
      WHERE mr.MemberMciSecondary_IDNO = @An_MemberMciPrimary_IDNO
        AND mr.StatusMerge_CODE = @Lc_StatusMergePending_CODE
        AND mr.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Count > 0
      BEGIN
       SET @Ac_Msg_CODE = 'M';
       SET @As_DescriptionError_TEXT = 'PRIMARY MEMBER ALREADY EXISTS AS SECONDARY MEMBER';

       RETURN;
      END

     /*
      14. Secondary Member already existed as a Primary or Secondary Member
      N - E1028 Secondary Member already exists as a Primary or Secondary Member
      */
     SET @Ls_Sql_TEXT = 'SELECT MMRG2';

     SELECT TOP 1 @Ln_Count = COUNT(1)
       FROM MMRG_Y1 mr
      WHERE (mr.MemberMciPrimary_IDNO = @An_MemberMciSecondary_IDNO
              OR mr.MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO)
        AND mr.StatusMerge_CODE = @Lc_StatusMergePending_CODE
        AND mr.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Count > 0
      BEGIN
       SET @Ac_Msg_CODE = 'N';
       SET @As_DescriptionError_TEXT = 'SECONDARY MEMBER ALREADY EXISTS AS A PRIMARY OR SECONDARY MEMBER';

       RETURN;
      END

     /*
     15. The system will display a warning message of "Merge is already Pending",
     if the secondary member is already in the Pending Merge Queue
     O - E1029  Merge request is already pending
     */
     SET @Ls_Sql_TEXT = 'SELECT MMRG3';

     SELECT TOP 1 @Ln_Count = COUNT(1)
       FROM MMRG_Y1 mr
      WHERE mr.MemberMciPrimary_IDNO = @An_MemberMciPrimary_IDNO
        AND mr.MemberMciSecondary_IDNO = @An_MemberMciSecondary_IDNO
        AND mr.StatusMerge_CODE = @Lc_StatusMergePending_CODE
        AND mr.EndValidity_DATE = @Ld_High_DATE;

     IF @Ln_Count > 0
      BEGIN
       SET @Ac_Msg_CODE = 'O';
       SET @As_DescriptionError_TEXT = 'MERGE REQUEST IS ALREADY PENDING FOR THE MEMBERS';

       RETURN;
      END
    END

   SET @Ac_Msg_CODE = 'S';
   SET @As_DescriptionError_TEXT = '';
  END TRY

  BEGIN CATCH
   ----- Expection for CURSOR
   IF CURSOR_STATUS('LOCAL', '@Mhis_CUR') IN (0, 1)
    BEGIN
     CLOSE @Mhis_CUR;

     DEALLOCATE @Mhis_CUR;
    END

   IF CURSOR_STATUS('LOCAL', '@Cmem_CUR') IN (0, 1)
    BEGIN
     CLOSE @Cmem_CUR;

     DEALLOCATE @Cmem_CUR;
    END

   SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
   SET @Ln_Error_NUMB = ERROR_NUMBER();
   SET @Ln_ErrorLine_NUMB = ERROR_LINE();

   IF @Ln_Error_NUMB <> 50001
    BEGIN
     SET @As_DescriptionError_TEXT = SUBSTRING (ERROR_MESSAGE (), 1, 200);
    END;

   EXECUTE BATCH_COMMON$SP_GET_ERROR_DESCRIPTION
    @As_Procedure_NAME        = @Ls_Procedure_NAME,
    @As_ErrorMessage_TEXT     = @As_DescriptionError_TEXT,
    @As_Sql_TEXT              = @Ls_Sql_TEXT,
    @As_Sqldata_TEXT          = @Ls_Sqldata_TEXT,
    @An_Error_NUMB            = @Ln_Error_NUMB,
    @An_ErrorLine_NUMB        = @Ln_ErrorLine_NUMB,
    @As_DescriptionError_TEXT = @As_DescriptionError_TEXT OUTPUT;
    
  END CATCH
 END


GO
