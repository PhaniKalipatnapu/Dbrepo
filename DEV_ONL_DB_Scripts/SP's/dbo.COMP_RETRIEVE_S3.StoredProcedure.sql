/****** Object:  StoredProcedure [dbo].[COMP_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[COMP_RETRIEVE_S3]  
(
     @An_Compliance_IDNO		    NUMERIC(19,0),
     @An_Case_IDNO		            NUMERIC(6,0),
     @An_TransactionEventSeq_NUMB	NUMERIC(19,0)	 OUTPUT,
     @Ac_ComplianceStatus_CODE		CHAR(2)	         OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : COMP_RETRIEVE_S3
 *     DESCRIPTION       : Retrieves the transaction event sequence number and compliance schedule status 
						   for the given case and compliance schedule number.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 17-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

      SELECT @An_TransactionEventSeq_NUMB = NULL,
			 @Ac_ComplianceStatus_CODE    = NULL;

      DECLARE @Ld_High_DATE	 DATE = '12/31/9999';
        
      SELECT @An_TransactionEventSeq_NUMB = a.TransactionEventSeq_NUMB, 
             @Ac_ComplianceStatus_CODE    = a.ComplianceStatus_CODE
        FROM COMP_Y1 a
       WHERE a.Compliance_IDNO  = @An_Compliance_IDNO  
         AND a.Case_IDNO        = @An_Case_IDNO  
         AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END  --END OF COMP_RETRIEVE_S3


GO
