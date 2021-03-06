/****** Object:  StoredProcedure [dbo].[CPFL_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPFL_RETRIEVE_S1] (
 @An_Case_IDNO		   NUMERIC(6,0),
 @An_AssessedYear_NUMB NUMERIC(4,0),
 @An_MemberMci_IDNO	   NUMERIC(10,0),
 @Ac_FeeType_CODE      CHAR(2),
 @Ad_From_DATE         DATE,          
 @Ad_To_DATE           DATE,       
 @Ai_RowFrom_NUMB      INT=1,
 @Ai_RowTo_NUMB        INT=10              
 )
AS
/*
 *     PROCEDURE NAME    : CPFL_RETRIEVE_S1
 *     DESCRIPTION       : Retrieveing the cp fees deatils.
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 10-AUG-2011 
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
BEGIN

DECLARE @Lc_FeeTypeAp_CODE         CHAR(2) ='AP',
        @Lc_TransactionAsmt_CODE   CHAR(4) ='ASMT',
        @Lc_TransactionRdca_CODE   CHAR(4) ='RDCA',
        @Lc_TransactionSrec_CODE   CHAR(4) ='SREC',
        @Lc_TransactionRdcr_CODE   CHAR(4) ='RDCR',
        @Li_Zero_NUMB              INT =0,
		@Lc_Space_TEXT             CHAR(1) =' ',
		@Lc_CaseRelationShipC_CODE CHAR(1) ='C',
        @Ld_High_DATE              DATE = '12/31/9999';             

SELECT Y.Case_IDNO,
	   Y.MemberMCI_IDNO,
       Y.AssessedYear_NUMB, 
       Y.TransactionEventSeq_NUMB, 
       Y.FeeType_CODE, 
       Y.Assessed_AMNT, 
       Y.Paid_AMNT, 
       Y.Waived_AMNT, 
       Y.DescriptionReason_TEXT,
       Y.Worker_ID, 
       Y.Event_DTTM,
       Y.Last_NAME,
       Y.First_NAME,
       Y.Middle_NAME,
       Y.RowCount_NUMB 
FROM (SELECT X.Case_IDNO, 
		     X.MemberMCI_IDNO,
             X.AssessedYear_NUMB, 
             X.FeeType_CODE, 
             X.Assessed_AMNT, 
             X.Paid_AMNT, 
             X.Waived_AMNT,  
             X.DescriptionReason_TEXT, 
             X.TransactionEventSeq_NUMB, 
             X.Worker_ID, 
             X.Event_DTTM,
             x.Last_NAME,
             X.First_NAME,
             X.Middle_NAME,
             X.RowCount_NUMB, 
             X.Row_NUMB
FROM (SELECT x.Case_IDNO,
		     x.MemberMCI_IDNO,
		     x.AssessedYear_NUMB,
		     x.FeeType_CODE,
		     x.Assessed_AMNT,
		     x.Paid_AMNT,
		     x.Waived_AMNT,
		     x.DescriptionReason_TEXT,
		     x.Event_DTTM,
		     x.Worker_ID,
		     d.Last_NAME,
             d.First_NAME,
             d.Middle_NAME,
		     x.TransactionEventSeq_NUMB,
             COUNT(1) OVER() AS RowCount_NUMB, 
             ROW_NUMBER() OVER(
                        ORDER BY x.Event_DTTM DESC) AS Row_NUMB
FROM (SELECT B.Case_IDNO,
		     B.AssessedYear_NUMB,
		     B.FeeType_CODE,
		     B.MemberMci_IDNO,
		     B.Assessed_AMNT,
		     B.Paid_AMNT,
		     @Li_Zero_NUMB AS Waived_AMNT,
		     @Lc_Space_TEXT AS DescriptionReason_TEXT,
		     G.Event_DTTM,
		     G.Worker_ID,
		     B.EventGlobalSeq_NUMB TransactionEventSeq_NUMB
 FROM(SELECT DISTINCT A.Case_IDNO,
		     A.AssessedYear_NUMB,
		     A.FeeType_CODE,
		     A.MemberMci_IDNO,
		     SUM(ISNULL(A.Assessed_AMNT,0)) OVER(PARTITION BY A.Case_IDNO, A.AssessedYear_NUMB, A.FeeType_CODE) AS Assessed_AMNT,
		     SUM(ISNULL(A.Paid_AMNT,0)) OVER(PARTITION BY A.Case_IDNO, A.AssessedYear_NUMB, A.FeeType_CODE) AS Paid_AMNT,
		     MAX(A.EventGlobalSeq_NUMB)OVER(PARTITION BY A.Case_IDNO, A.AssessedYear_NUMB, A.FeeType_CODE) AS EventGlobalSeq_NUMB
	FROM (SELECT C.Case_IDNO,
		         C.AssessedYear_NUMB,
		         C.FeeType_CODE,
		         C.MemberMci_IDNO,
		         CASE  WHEN C.Transaction_CODE IN(@Lc_TransactionAsmt_CODE,@Lc_TransactionRdca_CODE) THEN C.Transaction_AMNT 
		         END AS Assessed_AMNT,
		         CASE WHEN C.Transaction_CODE IN(@Lc_TransactionSrec_CODE,@Lc_TransactionRdcr_CODE)  THEN C.Transaction_AMNT 
		         END AS Paid_AMNT,
		         C.EventGlobalSeq_NUMB
	  FROM CPFL_Y1 C
	  WHERE C.MemberMci_IDNO =ISNULL(@An_MemberMci_IDNO,C.MemberMci_IDNO)
	    AND C.Case_IDNO=ISNULL(@An_Case_IDNO,C.Case_IDNO)  	
	    AND C.FeeType_CODE=ISNULL(@Ac_FeeType_CODE,C.FeeType_CODE)  
	    AND C.AssessedYear_NUMB = ISNULL(@An_AssessedYear_NUMB,C.AssessedYear_NUMB)
	    AND (C.Transaction_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE OR @Ad_From_DATE IS NULL)
	  	  ) A )B
	  LEFT OUTER JOIN 
	  GLEV_Y1 G  
	  ON (B.EventGlobalSeq_NUMB=G.EventGlobalSeq_NUMB)
	
UNION ALL
	SELECT C.CASE_IDNO,
		   YEAR(C.BeginValidity_DATE) AS AessessdYear_NUMB,
		   @Lc_FeeTypeAp_CODE AS FeeType_CODE,
		   C1.MemberMci_IDNO,
		   C.Assessed_AMNT,
		   C.Paid_AMNT,
		   C.Waived_AMNT,
		   C.DescriptionReason_TEXT,
		   G.Event_DTTM,
		   G.Worker_ID,
		   C.TransactionEventSeq_NUMB
	  FROM CPAF_Y1 C
	  JOIN CMEM_Y1 C1 ON (C.CASE_IDNO =C1.CASE_IDNO AND C1.CaseRelationShip_CODE=@Lc_CaseRelationShipC_CODE)  
	  LEFT OUTER JOIN 
	  GLEC_Y1 G 
	  ON (c.TransactionEventSeq_NUMB=G.TransactionEventSeq_NUMB)
	  WHERE C.Case_IDNO=ISNULL(@An_Case_IDNO,C.Case_IDNO)  	
	    AND C1.MEMBERMCI_IDNO = ISNULL(@An_MemberMci_IDNO,C1.MEMBERMCI_IDNO)
	    AND (@Ac_FeeType_CODE= @Lc_FeeTypeAp_CODE OR @Ac_FeeType_CODE IS NULL)
	    AND (YEAR(C.BeginValidity_DATE)=@An_AssessedYear_NUMB OR @An_AssessedYear_NUMB IS NULL)
	    AND (C.Beginvalidity_DATE BETWEEN @Ad_From_DATE AND @Ad_To_DATE OR @Ad_From_DATE IS NULL)
	    AND C.EndValidity_DATE = @Ld_High_DATE
)X  LEFT OUTER JOIN 
 DEMO_Y1 d
 ON (X.MemberMci_IDNO=d.MemberMci_IDNO)

)X
WHERE (X.Row_NUMB <= @Ai_RowTo_NUMB 
   OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)
 )  AS Y
      WHERE (Y.Row_NUMB >= @Ai_RowFrom_NUMB 
         OR @Ai_RowFrom_NUMB = @Li_Zero_NUMB);
      
END;--End Of CPFL_RETRIEVE_S1


GO
