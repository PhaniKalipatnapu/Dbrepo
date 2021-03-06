/****** Object:  StoredProcedure [dbo].[RJDT_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RJDT_RETRIEVE_S1](
     @An_County_IDNO		NUMERIC(3,0),
     @An_MemberMci_IDNO		NUMERIC(10,0),
     @An_MemberSsn_NUMB		NUMERIC(9,0),                                           
     @Ac_TypeReject_CODE    CHAR(1),    
     @Ad_From_DATE			DATE,        
     @Ad_To_DATE			DATE,
     @Ac_HighProfile_INDC   CHAR(1),          
     @Ai_RowFrom_NUMB       INT =1 ,       
     @Ai_RowTo_NUMB         INT =10          
     )                  
AS    
/*      
 *     PROCEDURE NAME    : RJDT_RETRIEVE_S1      
 *     DESCRIPTION       : This procedure is used to populate the rejected records for top grid.      
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 27-NOV-2011      
 *     MODIFIED BY       :       
 *     MODIFIED ON       :       
 *     VERSION NO        : 1      
 */      
BEGIN 
		DECLARE @Li_Zero_NUMB           SMALLINT = 0,
				@Lc_TypeReject1X_CODE	CHAR(1) = 'X',
				@Ld_High_DATE			DATE  =  '12/31/9999';      
              		
		 SELECT Y.MemberMci_IDNO, 
				Y.MemberSsn_NUMB,
		        Y.Member_NAME,
		        Y.ArrearIdentifier_IDNO,
		        Y.County_IDNO, 
		        Y.TypeArrear_CODE,
		        Y.TransactionType_CODE,
		        Y.Rejected_DATE, 
		        Y.Reject1_CODE,
		        Y.Reject2_CODE, 
		        Y.Reject3_CODE,
		        Y.Reject4_CODE, 
		        Y.Reject5_CODE,
		        Y.Reject6_CODE,
		        Y.TypeReject1_CODE,
		        Y.TypeReject2_CODE,
		        Y.TypeReject3_CODE,
		        Y.TypeReject4_CODE,
		        Y.TypeReject5_CODE,
		        Y.TypeReject6_CODE,
		        Y.WorkerUpdate_ID,
		        Y.TransactionEventSeq_NUMB,
		        Y.RowCount_NUMB
		   FROM (
				 SELECT X.MemberMci_IDNO, 
						X.MemberSsn_NUMB, 
						X.Member_NAME,
						X.ArrearIdentifier_IDNO, 
						X.County_IDNO, 
						X.TypeArrear_CODE,
						X.TransactionType_CODE, 
						X.Rejected_DATE, 
						X.Reject1_CODE,
						X.Reject2_CODE, 
						X.Reject3_CODE, 
						X.Reject4_CODE,
						X.Reject5_CODE, 
						X.Reject6_CODE, 
						X.TypeReject1_CODE,
						X.TypeReject2_CODE, 
						X.TypeReject3_CODE, 
						X.TypeReject4_CODE,
						X.TypeReject5_CODE, 
						X.TypeReject6_CODE, 
						X.WorkerUpdate_ID,
						X.TransactionEventSeq_NUMB, 
						X.RowCount_NUMB, 
						X.ORD_ROWNUM AS rnm
				   FROM (
						 SELECT a.MemberMci_IDNO, 
								a.MemberSsn_NUMB,
								dbo.BATCH_COMMON$SF_GET_MASKED_MEMBER_NAME1(a.MemberMci_IDNO,@Ac_HighProfile_INDC) AS Member_NAME,
								a.ArrearIdentifier_IDNO, 
								a.County_IDNO,
								a.TypeArrear_CODE, 
								a.TransactionType_CODE,
								a.Rejected_DATE, 
								a.Reject1_CODE, 
								a.Reject2_CODE,
								a.Reject3_CODE, 
								a.Reject4_CODE, 
								a.Reject5_CODE,
								a.Reject6_CODE, 
								a.TypeReject1_CODE,
								a.TypeReject2_CODE, 
								a.TypeReject3_CODE,
								a.TypeReject4_CODE, 
								a.TypeReject5_CODE,
								a.TypeReject6_CODE, 
								a.WorkerUpdate_ID,
								a.TransactionEventSeq_NUMB, 
								a.EndValidity_DATE,
								COUNT (1) OVER () AS RowCount_NUMB,
								ROW_NUMBER () OVER (ORDER BY a.Rejected_DATE DESC) AS ORD_ROWNUM
						   FROM RJDT_Y1 a
						  WHERE (EXISTS ( 
										  SELECT 1
											FROM RJCS_Y1 c
										   WHERE c.County_IDNO   = @An_County_IDNO
											 AND  c.MemberMci_IDNO = a.MemberMci_IDNO)
									 OR @An_County_IDNO IS NULL
		                         )
							AND (  a.County_IDNO = @An_County_IDNO
								 OR @An_County_IDNO IS NULL
								)
							AND ( a.MemberMci_IDNO	= @An_MemberMci_IDNO
								 OR @An_MemberMci_IDNO IS NULL
								)
							AND ( a.MemberSsn_NUMB	= @An_MemberSsn_NUMB
								 OR @An_MemberSsn_NUMB IS NULL
								)
							AND ( a.Rejected_DATE	>= @Ad_From_DATE
								 OR @Ad_From_DATE IS NULL
								)
							AND ( a.Rejected_DATE	<= @Ad_To_DATE
								 OR @Ad_To_DATE IS NULL
								)
							AND ( a.TypeReject1_CODE = @Ac_TypeReject_CODE
								 OR a.TypeReject2_CODE = @Ac_TypeReject_CODE
								 OR a.TypeReject3_CODE = @Ac_TypeReject_CODE
								 OR a.TypeReject4_CODE = @Ac_TypeReject_CODE
								 OR a.TypeReject5_CODE = @Ac_TypeReject_CODE
								 OR a.TypeReject6_CODE = @Ac_TypeReject_CODE
								 OR @Ac_TypeReject_CODE IS NULL
								)
							AND a.EndValidity_DATE = @Ld_High_DATE) X
				  WHERE ( X.TypeReject1_CODE <> @Lc_TypeReject1X_CODE
							OR X.TypeReject1_CODE IS NULL
							OR ( X.TypeReject1_CODE = @Lc_TypeReject1X_CODE
								AND ( X.TypeReject2_CODE IS NOT NULL
									 OR X.TypeReject3_CODE IS NOT NULL
									 OR X.TypeReject4_CODE IS NOT NULL
									 OR X.TypeReject5_CODE IS NOT NULL
									 OR X.TypeReject6_CODE IS NOT NULL
									)
								)
						)
					AND (ORD_ROWNUM <= @Ai_RowTo_NUMB 
						 OR @Ai_RowTo_NUMB = @Li_Zero_NUMB)) Y
		  WHERE (Y.rnm >= @Ai_RowFrom_NUMB 
				 OR	@Ai_RowFrom_NUMB = @Li_Zero_NUMB)
	   ORDER BY RNM;
END;   --End of RJDT_RETRIEVE_S1.    

GO
