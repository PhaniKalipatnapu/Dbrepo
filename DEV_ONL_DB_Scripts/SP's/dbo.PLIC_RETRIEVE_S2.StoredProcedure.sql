/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S2](  
 	 @An_MemberMci_IDNO		NUMERIC(10,0),
 	 @Ac_TypeLicense_CODE	CHAR(5)		 , 
     @Ai_RowFrom_NUMB       INT =1       ,    
     @Ai_RowTo_NUMB         INT =10         
     )  
AS    
    
/*    
 *     PROCEDURE NAME    : PLIC_RETRIEVE_S2    
 *     DESCRIPTION       : Retrieve License Details for a Member ID, License Type Code.    
 *     DEVELOPED BY      : IMP Team    
 *     DEVELOPED ON      : 07-SEP-2011    
 *     MODIFIED BY       :     
 *     MODIFIED ON       :     
 *     VERSION NO        : 1    
 */    
    BEGIN    
    
  DECLARE    
         @Ld_High_DATE DATE =  '12/31/9999';   
              
 
		SELECT   Y.TypeLicense_CODE,
				 Y.LicenseNo_TEXT,
				 Y.TransactionEventSeq_NUMB,
				 Y.IssueLicense_DATE,
		         Y.SuspLicense_DATE,
		         Y.OtherParty_NAME,		         
		         Y.RowCount_NUMB 
		    FROM (SELECT X.TypeLicense_CODE, 
		    			 X.OtherParty_NAME, 
		    			 X.LicenseNo_TEXT,
		                 X.IssueLicense_DATE, 
		                 X.SuspLicense_DATE,
		                 X.TransactionEventSeq_NUMB, 
		                 X.ORD_ROWNUM rnm, 
		                 X.RowCount_NUMB
		            FROM (SELECT a.TypeLicense_CODE, 
		            			 b.OtherParty_NAME,
		                         a.LicenseNo_TEXT, 
		                         a.IssueLicense_DATE,
		                         a.SuspLicense_DATE, 
		                         a.TransactionEventSeq_NUMB,
		                         COUNT (1) OVER () AS RowCount_NUMB,
		                         ROW_NUMBER () OVER (ORDER BY a.LicenseStatus_CODE ASC,
		                          a.IssueLicense_DATE DESC,
		                          a.TransactionEventSeq_NUMB DESC) ORD_ROWNUM
		                    FROM PLIC_Y1 a JOIN OTHP_Y1 b
		                    ON a.OthpLicAgent_IDNO = b.OtherParty_IDNO
		                   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
		                     AND (   @Ac_TypeLicense_CODE IS NULL
		                          OR a.TypeLicense_CODE = @Ac_TypeLicense_CODE
		                         )
		                     AND a.EndValidity_DATE = @Ld_High_DATE
		                     AND b.EndValidity_DATE = @Ld_High_DATE) X
		           WHERE X.ORD_ROWNUM <= @Ai_RowTo_NUMB) Y
		   WHERE Y.rnm >= @Ai_RowFrom_NUMB
		ORDER BY RNM;

  
END;   --End of PLIC_RETRIEVE_S2      


GO
