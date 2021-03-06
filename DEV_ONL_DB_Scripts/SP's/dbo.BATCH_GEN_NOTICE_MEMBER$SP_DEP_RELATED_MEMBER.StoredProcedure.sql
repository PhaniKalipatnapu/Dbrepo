/****** Object:  StoredProcedure [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_DEP_RELATED_MEMBER]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
--------------------------------------------------------------------------------------------------------------------
Procedure Name	:	BATCH_GEN_NOTICE_MEMBER$SP_DEP_RELATED_MEMBER
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
CREATE PROCEDURE [dbo].[BATCH_GEN_NOTICE_MEMBER$SP_DEP_RELATED_MEMBER]
(
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Msg_CODE              CHAR(5) OUTPUT,
 @As_DescriptionError_TEXT VARCHAR(4000) OUTPUT
)
AS
 BEGIN
  BEGIN TRY
   DECLARE @Ls_StatusCaseMemberActive_CODE     CHAR = 'A',
           @Lc_Yes_TEXT                        CHAR = 'Y',
           @Lc_StatusSuccess_CODE              CHAR = 'S',
           @Lc_StatusFailed_CODE               CHAR = 'F',
           @LC_RelationshipCaseCp_TEXT         CHAR(1) = 'C',
           @Lc_RelationshipCaseDp_TEXT         CHAR(1) = 'D',
           @Lc_RelationshipCaseNcp_TEXT        CHAR(1) = 'A',
           @Lc_RelationshipCasePutFather_TEXT  CHAR(1) = 'P',
           @Lc_RelationshipToChildM1_TEXT      CHAR(3) = 'M',
           @Lc_RelationshipToDep1MTR_TEXT      CHAR(3) = 'MTR',
           @Lc_RelationshipToChildF1_TEXT      CHAR(3) = 'F',
           @Lc_RelationshipToDep2FTR_TEXT      CHAR(3) = 'FTR',
           @Lc_RelationshipToChildG1_TEXT      CHAR(3) = 'G',
           @Ls_Procedure_NAME                  VARCHAR(100) = 'BATCH_GEN_NOTICE_MEMBER$SP_DEP_RELATED_MEMBER';
           
  DECLARE  @Ls_MotherMemberMci_IDNO      NUMERIC(10),
           @Ls_FatherMemberMci_IDNO      NUMERIC(10),
           @Ls_CaretakerMemberMci_IDNO   NUMERIC(10),
           @Ln_RowCount_QNTY             INT = 0,
           @Lc_RelationshipToChild_TEXT  CHAR(1),
           @Ls_Sql_TEXT                  VARCHAR(200),
           @Ls_Sqldata_TEXT              VARCHAR(400),
           @Ls_DescriptionError_TEXT     VARCHAR(4000);

   SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CONVERT(VARCHAR(6), @An_Case_IDNO), '') 
									  + 'RELATION_TO_DEP =' + ISNULL(@Lc_RelationshipToChild_TEXT, '');
   
   SET @Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildM1_TEXT;
   IF(@Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildM1_TEXT)
    BEGIN
     SELECT @Ls_MotherMemberMci_IDNO = C.MemberMci_IDNO
       FROM CMEM_Y1 AS C
      WHERE C.Case_IDNO = @An_Case_IDNO
        AND C.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
        AND (C.CaseRelationship_CODE = @LC_RelationshipCaseCp_TEXT
             AND EXISTS (SELECT M.MemberMci_IDNO
                           FROM CMEM_Y1 AS M
                          WHERE M.Case_IDNO = @An_Case_IDNO
                            AND M.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                            AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                            AND (M.CpRelationshipToChild_CODE IN (@Lc_RelationshipToDep1MTR_TEXT))))

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = 0)
      BEGIN
       SELECT @Ls_MotherMemberMci_IDNO = C.MemberMci_IDNO
         FROM CMEM_Y1 AS C
        WHERE C.Case_IDNO = @An_Case_IDNO
          AND C.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
          AND (C.CaseRelationship_CODE IN(@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
               AND EXISTS (SELECT M.MemberMci_IDNO
                             FROM CMEM_Y1 AS M
                            WHERE M.Case_IDNO = @An_Case_IDNO
                              AND M.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                              AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                              AND (M.NcpRelationshipToChild_CODE IN (@Lc_RelationshipToDep1MTR_TEXT))))
      END
    END

   SET @Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildF1_TEXT;
   SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CONVERT(VARCHAR(6), @An_Case_IDNO), '') 
						+ 'RELATION_TO_DEP =' + ISNULL(@Lc_RelationshipToChild_TEXT, '');

   IF(@Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildF1_TEXT)
    BEGIN
     SELECT @Ls_FatherMemberMci_IDNO = C.MemberMci_IDNO
       FROM CMEM_Y1 AS C
      WHERE C.Case_IDNO = @An_Case_IDNO
        AND C.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
        AND (C.CaseRelationship_CODE IN(@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
             AND EXISTS (SELECT M.MemberMci_IDNO
                           FROM CMEM_Y1 AS M
                          WHERE M.Case_IDNO = @An_Case_IDNO
                            AND M.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                            AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                            AND (M.NcpRelationshipToChild_CODE IN (@Lc_RelationshipToDep2FTR_TEXT))))

     SET @Ln_RowCount_QNTY = @@ROWCOUNT;

     IF (@Ln_RowCount_QNTY = 0)
      BEGIN
       SELECT @Ls_FatherMemberMci_IDNO = C.MemberMci_IDNO
         FROM CMEM_Y1 AS C
        WHERE C.Case_IDNO = @An_Case_IDNO
          AND C.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
          AND (C.CaseRelationship_CODE IN(@LC_RelationshipCaseCp_TEXT)
               AND EXISTS (SELECT M.MemberMci_IDNO
                             FROM CMEM_Y1 AS M
                            WHERE M.Case_IDNO = @An_Case_IDNO
                              AND M.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                              AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                              AND (M.CpRelationshipToChild_CODE IN (@Lc_RelationshipToDep2FTR_TEXT))))

       SET @Ln_RowCount_QNTY = @@ROWCOUNT;

       IF (@Ln_RowCount_QNTY = 0)
        BEGIN
         SELECT @Ls_FatherMemberMci_IDNO = c.MemberMci_IDNO
           FROM CMEM_Y1 c
          WHERE c.Case_IDNO = @An_Case_IDNO
            AND c.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
            AND (c.CaseRelationship_CODE IN(@Lc_RelationshipCaseNcp_TEXT, @Lc_RelationshipCasePutFather_TEXT)
                 AND NOT EXISTS (SELECT 1
                                   FROM CMEM_Y1 m
                                  WHERE m.Case_IDNO = c.Case_IDNO
                                    AND m.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                                    AND m.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                                    AND LTRIM(RTRIM(m.NcpRelationshipToChild_CODE)) IS NOT NULL)
                 AND EXISTS (SELECT e.MemberMci_IDNO
                               FROM 
                                    MPAT_Y1 d,
									CMEM_Y1 e
                              WHERE e.Case_IDNO = @An_Case_IDNO
                                AND e.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                                AND e.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                                AND e.MemberMci_IDNO = d.MemberMci_IDNO
                                AND d.PaternityEst_INDC = @Lc_Yes_TEXT))
        END
      END
    END

   SET @Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildG1_TEXT;
   SET @Ls_Sql_TEXT = 'SELECT CMEM_Y1';
   SET @Ls_Sqldata_TEXT = ' Case_IDNO = ' + ISNULL(CONVERT(VARCHAR(6), @An_Case_IDNO), '') 
						+ 'RELATION_TO_DEP =' + ISNULL(@Lc_RelationshipToChild_TEXT, '');

   IF(@Lc_RelationshipToChild_TEXT = @Lc_RelationshipToChildG1_TEXT)
    BEGIN
      SELECT @Ls_CaretakerMemberMci_IDNO = C.MemberMci_IDNO
			FROM CMEM_Y1 AS C
		WHERE C.Case_IDNO = @An_Case_IDNO
        AND C.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
        AND (C.CaseRelationship_CODE = @LC_RelationshipCaseCp_TEXT
             AND EXISTS (SELECT M.MemberMci_IDNO
                           FROM CMEM_Y1 M
                          WHERE M.Case_IDNO = @An_Case_IDNO
                            AND M.CaseMemberStatus_CODE = @Ls_StatusCaseMemberActive_CODE
                            AND M.CaseRelationship_CODE = @Lc_RelationshipCaseDp_TEXT
                            AND M.CpRelationshipToChild_CODE != ''
                            AND (M.CpRelationshipToChild_CODE NOT IN (@Lc_RelationshipToDep1MTR_TEXT,@Lc_RelationshipToDep2FTR_TEXT))))
                            
    END

   INSERT INTO #NoticeElementsData_P1
               (Element_NAME,
                Element_Value)
   (SELECT tag_name,
           tag_value
      FROM (SELECT CONVERT(VARCHAR(100), CARETAKERMCI_IDNO) CARETAKERMCI_IDNO,
                   CONVERT(VARCHAR(100), MotherMCI_IDNO) MotherMCI_IDNO,
                   CONVERT(VARCHAR(100), FatherMCI_IDNO) FatherMCI_IDNO
              FROM (SELECT @Ls_CaretakerMemberMci_IDNO AS CARETAKERMCI_IDNO,
                           @Ls_MotherMemberMci_IDNO AS MotherMCI_IDNO,
                           @Ls_FatherMemberMci_IDNO AS FatherMCI_IDNO) h)up 
                UNPIVOT (tag_value FOR tag_name IN ( CARETAKERMCI_IDNO, MotherMCI_IDNO, FatherMCI_IDNO )) AS pvt);

  SET @Ac_Msg_CODE = @Lc_StatusSuccess_CODE;
  END TRY
  BEGIN CATCH
      SET @Ac_Msg_CODE = @Lc_StatusFailed_CODE;
         DECLARE @Li_Error_NUMB INT, @Li_ErrorLine_NUMB INT;
         SET @Li_Error_NUMB = ERROR_NUMBER ();
         SET @Li_ErrorLine_NUMB = ERROR_LINE ();

         IF (@Li_Error_NUMB <> 50001)
            BEGIN
               SET @Ls_DescriptionError_TEXT =   SUBSTRING (ERROR_MESSAGE (), 1, 200);
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
