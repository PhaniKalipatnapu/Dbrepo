/****** Object:  StoredProcedure [dbo].[DISH_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DISH_RETRIEVE_S2] (
 @An_PayorMci_IDNO		NUMERIC(10),
 @An_Case_IDNO			NUMERIC(6),
 @Ai_RowFrom_NUMB		INT = 1,
 @Ai_RowTo_NUMB			INT = 10
 )
AS
 /*  
  *     PROCEDURE NAME    : DISH_RETRIEVE_S2  
  *     DESCRIPTION       :  Retrieves the distribution hold details
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 30-SEP-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Lc_No_INDC                        CHAR(1) = 'N',
          @Lc_CaseRelationshipNcp_CODE       CHAR(1) = 'A',
          @Lc_CaseRelationshipPutFather_CODE CHAR(1) = 'P',
          @Lc_Space_TEXT                     CHAR(1) = ' ',
          @Lc_CaseMemberStatusActive_CODE    CHAR(1) = 'A',
          @Lc_TypeHoldPostingCase_CODE       CHAR(1) = 'C',
          @Lc_TypeHoldPostingPayor_CODE      CHAR(1) = 'P',
          @Ld_High_DATE                      DATE = '12/31/9999',
          @Ld_Low_DATE						 DATE = '01/01/0001',
          @Li_Zero_NUMB                      SMALLINT = 0,
          @Lc_StatusCheckActive_TEXT         CHAR(9) = 'ACTIVE-RU',
          @Lc_StatusCheckInactive_TEXT       CHAR(11) = 'INACTIVE-RU',
          @Lc_DescriptionNoteAdded_TEXT      CHAR(25) = 'NSF Indicator Checked: ',
          @Lc_DescriptionNoteRemoved_TEXT    CHAR(25) = 'NSF Indicator Unchecked: ',
          @Lc_StatusActive_TEXT              CHAR(6) = 'ACTIVE',
          @Lc_StatusInactive_TEXT            CHAR(8) = 'INACTIVE',
          @Lc_TableBchk_Indc				 CHAR(1) = 'B',
          @Lc_TableDish_Indc				 CHAR(1) = 'D',
          @Ld_Current_DATE                   DATE = dbo.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  SELECT m.PayorMCI_IDNO,
         m.SourceHold_CODE,
         m.EventGlobalBeginSeq_NUMB,
         m.ReasonHold_CODE,
         m.Effective_DATE,
         m.Expiration_DATE,
         m.Sequence_NUMB,
         m.BeginValidity_DATE,
         m.EndValidity_DATE,
         m.Case_IDNO,
         m.Status_TEXT,
         m.DescriptionNote_TEXT,
         m.Worker_ID,
         m.RowCount_NUMB
    FROM (SELECT l.PayorMCI_IDNO,
                 l.Case_IDNO,
                 l.SourceHold_CODE,
                 l.ReasonHold_CODE,
                 l.DescriptionNote_TEXT,
                 l.Effective_DATE,
                 l.Expiration_DATE,
                 l.Status_TEXT,
                 l.Worker_ID,
                 l.EventGlobalBeginSeq_NUMB,
                 l.Sequence_NUMB,
                 l.BeginValidity_DATE,
                 l.EndValidity_DATE,
                 l.ORD_ROWNUM AS rnm,
                 l.RowCount_NUMB
            FROM (SELECT k.PayorMCI_IDNO,
                         k.Case_IDNO,
                         k.SourceHold_CODE,
                         k.ReasonHold_CODE,
                         k.DescriptionNote_TEXT,
                         CASE WHEN k.Table_Indc = @Lc_TableBchk_Indc
                         THEN h.Event_DTTM
                         ELSE k.Effective_DATE
                         END AS Effective_DATE,
                         CASE k.Expiration_DATE
                          WHEN @Ld_High_DATE
                           THEN NULL
                          ELSE k.Expiration_DATE
                         END AS Expiration_DATE,                         
                         k.Status_TEXT,
                         h.Worker_ID,
                         k.EventGlobalBeginSeq_NUMB,
                         k.Sequence_NUMB,
                         CASE WHEN k.Table_Indc = @Lc_TableBchk_Indc
                         THEN  h.Event_DTTM
                         ELSE k.BeginValidity_DATE
                         END AS BeginValidity_DATE,
                         k.EndValidity_DATE,
                         COUNT (1) OVER () AS RowCount_NUMB,
                         ROW_NUMBER () OVER (ORDER BY k.Expiration_DATE DESC, k.EventGlobalBeginSeq_NUMB DESC) AS ORD_ROWNUM
                    FROM (SELECT CASE a.TypeHold_CODE
                                  WHEN @Lc_TypeHoldPostingPayor_CODE
                                   THEN a.CasePayorMci_IDNO
                                  ELSE @Li_Zero_NUMB
                                 END AS PayorMCI_IDNO,
                                 CASE a.TypeHold_CODE
                                  WHEN @Lc_TypeHoldPostingCase_CODE
                                   THEN a.CasePayorMci_IDNO
                                  ELSE @Li_Zero_NUMB
                                 END AS Case_IDNO,
                                 a.SourceHold_CODE,
                                 a.ReasonHold_CODE,
                                 b.DescriptionNote_TEXT,
                                 a.Effective_DATE,
                                 @Lc_TableDish_Indc AS Table_Indc,
                                 a.Expiration_DATE,                                 
                                 CASE
                                  WHEN (a.Expiration_DATE <= @Ld_Current_DATE
                                         OR a.Effective_DATE > @Ld_Current_DATE)
                                   THEN @Lc_StatusInactive_TEXT
                                  ELSE @Lc_StatusActive_TEXT
                                 END AS Status_TEXT,
                                 a.EventGlobalBeginSeq_NUMB,
                                 a.Sequence_NUMB,
                                 a.BeginValidity_DATE,
                                 a.EndValidity_DATE
                            FROM DISH_Y1 a
                                 LEFT OUTER JOIN UNOT_Y1 b
                                  ON b.EventGlobalSeq_NUMB = a.EventGlobalBeginSeq_NUMB
                           WHERE a.CasePayorMci_IDNO IN (SELECT CASE WHEN a.TypeHold_CODE = @Lc_TypeHoldPostingPayor_CODE
																	 THEN d.MemberMci_IDNO
																	 ELSE d.Case_IDNO
																END CasePayorMci_IDNO
                                                           FROM CMEM_Y1 d
                                                          WHERE d.Case_IDNO = ISNULL(@An_Case_IDNO, d.Case_IDNO)
															AND d.MemberMci_IDNO = @An_PayorMci_IDNO
                                                            AND d.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                            AND d.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE
                                                         )
                             AND a.EndValidity_DATE = @Ld_High_DATE
                          UNION ALL
                          SELECT f.MemberMci_IDNO,
                                 @Li_Zero_NUMB,
                                 @Lc_Space_TEXT AS SourceHold_CODE,
                                 @Lc_Space_TEXT AS ReasonHold_CODE,
                                 CASE
                                  WHEN f.BadCheck_INDC = @Lc_No_INDC
                                   THEN @Lc_DescriptionNoteRemoved_TEXT + ISNULL (g.DescriptionNote_TEXT, '')
                                  ELSE @Lc_DescriptionNoteAdded_TEXT + ISNULL (g.DescriptionNote_TEXT, '')
                                 END AS DescriptionNote_TEXT,
                                 @Ld_Low_DATE AS Effective_DATE,
                                 @Lc_TableBchk_Indc AS Table_Indc,
                                 @Ld_High_DATE AS Expiration_DATE,
                                 CASE
                                  WHEN f.BadCheck_INDC = @Lc_No_INDC
                                   THEN @Lc_StatusCheckInactive_TEXT
                                  ELSE @Lc_StatusCheckActive_TEXT
                                 END AS Status_TEXT,
                                 f.EventGlobalSeq_NUMB,
                                 @Li_Zero_NUMB AS Sequence_NUMB,
                                 @Ld_Low_DATE AS BeginValidity_DATE,

                                 CAST (@Ld_High_DATE AS DATETIME)AS EndValidity_DATE
                            FROM BCHK_Y1 f
                                 LEFT OUTER JOIN UNOT_Y1 g
                                  ON g.EventGlobalSeq_NUMB = f.EventGlobalSeq_NUMB
                           WHERE f.MemberMci_IDNO IN (SELECT i.MemberMci_IDNO
                                                        FROM CMEM_Y1 i
                                                       WHERE i.Case_IDNO = ISNULL(@An_Case_IDNO, i.Case_IDNO)
														 AND i.MemberMci_IDNO = @An_PayorMci_IDNO
                                                         AND i.CaseRelationship_CODE IN (@Lc_CaseRelationshipNcp_CODE, @Lc_CaseRelationshipPutFather_CODE)
                                                         AND i.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE)
                             AND f.EventGlobalSeq_NUMB = (SELECT MAX (j.EventGlobalSeq_NUMB)
                                                            FROM BCHK_Y1 j
                                                           WHERE j.MemberMci_IDNO = f.MemberMci_IDNO)
                           	) AS k JOIN GLEV_Y1 h ON 
                           h.EventGlobalSeq_NUMB = k.EventGlobalBeginSeq_NUMB )AS l
           WHERE l.ORD_ROWNUM <= @Ai_RowTo_NUMB)AS m
   WHERE m.rnm >= @Ai_RowFrom_NUMB
   ORDER BY RNM;
 END; -- END of DISH_RETRIEVE_S2

GO
