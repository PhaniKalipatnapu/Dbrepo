/****** Object:  StoredProcedure [dbo].[DPRS_RETRIEVE_S14]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DPRS_RETRIEVE_S14]( 

	@An_Case_IDNO		NUMERIC(6,0),
	@Ac_File_ID			CHAR(10),
	@Ai_RowFrom_NUMB	INT = 1,
	@Ai_RowTo_NUMB		INT = 10
	)   
AS

/*
 *     PROCEDURE NAME    : DPRS_RETRIEVE_S14
 *     DESCRIPTION       : Retrieving File Persons Detail for the given Case_ID and File_ID combination.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 10-AUG-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN


      DECLARE
         @Li_Zero_NUMB						SMALLINT = 0, 
         @Lc_StatusCaseMemberActive_CODE	CHAR(1) = 'A', 
         @Ld_High_DATE 						DATE = '12/31/9999',
		 @Lc_TypePartyNM_CODE				CHAR(2) = 'NM',
		 @Lc_TypePartyRA_CODE				CHAR(2) = 'RA',
		 @Lc_TypePartyPA_CODE				CHAR(2) = 'PA',
		 @Lc_TypePartyCI_CODE				CHAR(2) = 'CI',
		 @Lc_TypePartyCP_CODE				CHAR(2) = 'CP',
		 @Lc_TypePartyNCP_CODE				CHAR(3) = 'NCP',
		 @Lc_TypePartyGC_CODE				CHAR(2) = 'GC',
		 @Lc_TypePartyAttorney_CODE			CHAR(1) = 'A',
		 @Lc_CaseRelationshipA_CODE			CHAR(1) = 'A',
		 @Lc_CaseRelationshipC_CODE			CHAR(1) = 'C',
		 @Lc_CaseRelationshipP_CODE			CHAR(1) = 'P',
		 @Lc_CaseRelationshipD_CODE			CHAR(1) = 'D',
		 @Lc_CaseRelationshipG_CODE			CHAR(1) = 'G';
	  DECLARE
		 @Ld_Current_DATE					DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

		 
        
	 SELECT t.File_NAME, 
         	t.AttorneyAttn_NAME, 
         	t.IveParty_IDNO, 
         	t.DocketPerson_IDNO, 
         	t.Case_IDNO, 
         	t.TypePerson_CODE, 
         	t.EffectiveStart_DATE, 
         	t.EffectiveEnd_DATE, 
         	t.WorkerUpdate_ID, 
         	t.BeginValidity_DATE, 
         	t.TransactionEventSeq_NUMB,
			t.AssociatedMemberMci_IDNO, 
         	RowCount_NUMB
      FROM (
         SELECT X.DocketPerson_IDNO, 
               	 X.Case_IDNO, 
               	 X.TypePerson_CODE, 
               	 X.EffectiveStart_DATE, 
               	 X.EffectiveEnd_DATE, 
               	 X.WorkerUpdate_ID, 
               	 X.BeginValidity_DATE, 
               	 X.TransactionEventSeq_NUMB, 
               	 X.File_NAME, 
               	 X.AttorneyAttn_NAME, 
               	 X.IveParty_IDNO,
				 X.AssociatedMemberMci_IDNO, 
               	 X.RowCount_NUMB, 
               	 X.ORD_ROWNUM
            FROM (
               SELECT X.DocketPerson_IDNO, 
                       X.Case_IDNO, 
                       X.TypePerson_CODE, 
                       X.EffectiveStart_DATE, 
                       X.EffectiveEnd_DATE, 
                       X.WorkerUpdate_ID, 
                       X.BeginValidity_DATE, 
                       X.TransactionEventSeq_NUMB, 
                       X.File_NAME, 
                       X.AttorneyAttn_NAME, 
                       X.IveParty_IDNO,
					   X.AssociatedMemberMci_IDNO,
                       COUNT(1) OVER() AS RowCount_NUMB, 
                       ROW_NUMBER() OVER(
                          ORDER BY
                             X.EffectiveEnd_DATE DESC,
                             X.EffectiveStart_DATE) AS ORD_ROWNUM
                  FROM (
                     SELECT DISTINCT a.DocketPerson_IDNO, 
                             c.Case_IDNO, 
                             a.TypePerson_CODE, 
                             a.EffectiveStart_DATE, 
                             a.EffectiveEnd_DATE, 
                             a.WorkerUpdate_ID, 
                             a.BeginValidity_DATE, 
                             a.TransactionEventSeq_NUMB, 
                             a.File_NAME, 
                             a.AttorneyAttn_NAME, 
                             d.IveParty_IDNO,
							 a.AssociatedMemberMci_IDNO
                        FROM DPRS_Y1  a
                           	JOIN FDEM_Y1  m
                           		ON a.File_ID = m.File_ID
                           	JOIN CMEM_Y1  c
                           		ON m.Case_IDNO = c.Case_IDNO
                           		AND a.DocketPerson_IDNO = c.MemberMci_IDNO
                           	JOIN DEMO_Y1  d
                           		ON d.MemberMci_IDNO = c.MemberMci_IDNO
                        WHERE a.File_ID = @Ac_File_ID 
                          AND c.CaseMemberStatus_CODE = @Lc_StatusCaseMemberActive_CODE 
                          AND m.Case_IDNO = ISNULL(@An_Case_IDNO,m.Case_IDNO) 
                          AND @Ld_Current_DATE BETWEEN  a.EffectiveStart_DATE AND a.EffectiveEnd_DATE
                          AND a.EndValidity_DATE = @Ld_High_DATE
                          AND a.TypePerson_CODE NOT IN (@Lc_TypePartyNM_CODE,@Lc_TypePartyAttorney_CODE)
                          AND a.TypePerson_CODE =  CASE c.CaseRelationship_CODE 
														WHEN @Lc_CaseRelationshipD_CODE THEN @Lc_TypePartyCI_CODE
														WHEN @Lc_CaseRelationshipC_CODE THEN @Lc_TypePartyCP_CODE
														WHEN @Lc_CaseRelationshipA_CODE THEN @Lc_TypePartyNCP_CODE
														WHEN @Lc_CaseRelationshipP_CODE THEN @Lc_TypePartyNCP_CODE
														WHEN @Lc_CaseRelationshipG_CODE THEN @Lc_TypePartyGC_CODE END                        
                         UNION ALL
                        SELECT DISTINCT a.DocketPerson_IDNO, 
                           	   @Li_Zero_NUMB AS Case_IDNO,
                           	   ISNULL(
                           		CASE c.CaseRelationship_CODE
                           			WHEN @Lc_CaseRelationshipC_CODE THEN @Lc_TypePartyPA_CODE
                           			WHEN @Lc_CaseRelationshipA_CODE THEN @Lc_TypePartyRA_CODE
                           			WHEN @Lc_CaseRelationshipP_CODE THEN @Lc_TypePartyRA_CODE END,a.TypePerson_CODE) AS TypePerson_CODE,
                           	   a.EffectiveStart_DATE, 
                           	   a.EffectiveEnd_DATE, 
                           	   a.WorkerUpdate_ID, 
                           	   a.BeginValidity_DATE, 
                           	   a.TransactionEventSeq_NUMB, 
                           	   a.File_NAME, 
                           	   a.AttorneyAttn_NAME,
                           	      (
                           	         SELECT O.ReferenceOthp_IDNO
                           	         FROM OTHP_Y1 O
                           	         WHERE O.OtherParty_IDNO = a.DocketPerson_IDNO 
                           	         AND O.EndValidity_DATE = @Ld_High_DATE
                           	      ) AS IveParty_IDNO,
							   a.AssociatedMemberMci_IDNO
                        FROM DPRS_Y1 a
							LEFT OUTER JOIN CMEM_Y1 c
									 ON c.MemberMci_IDNO = a.AssociatedMemberMci_IDNO
								    AND c.Case_IDNO = @An_Case_IDNO
									AND c.CaseRelationship_CODE in (@Lc_CaseRelationshipC_CODE,@Lc_CaseRelationshipP_CODE,@Lc_CaseRelationshipA_CODE)
									AND a.TypePerson_CODE = @Lc_TypePartyAttorney_CODE
                        WHERE a.File_ID = @Ac_File_ID
                        AND a.TypePerson_CODE IN (@Lc_TypePartyNM_CODE,@Lc_TypePartyAttorney_CODE) 
                        AND a.EndValidity_DATE = @Ld_High_DATE
                        AND @Ld_Current_DATE BETWEEN  a.EffectiveStart_DATE AND a.EffectiveEnd_DATE
                     )  AS X
               )  AS X
            WHERE (X.ORD_ROWNUM <= @Ai_RowTo_NUMB 
            		OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)
         )  AS t
      WHERE (t.ORD_ROWNUM >= @Ai_RowFrom_NUMB 
      		OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB)
      ORDER BY
         t.EffectiveEnd_DATE DESC,
         t.EffectiveStart_DATE;

                  
END; --END OF DPRS_RETRIEVE_S14


GO
