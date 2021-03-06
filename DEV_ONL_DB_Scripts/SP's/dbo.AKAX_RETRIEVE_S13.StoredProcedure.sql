/****** Object:  StoredProcedure [dbo].[AKAX_RETRIEVE_S13]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[AKAX_RETRIEVE_S13]    
  (
     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @Ac_LastAlias_NAME		 CHAR(20) OUTPUT,
     @Ac_FirstAlias_NAME     CHAR(16) OUTPUT,
     @Ac_MiddleAlias_NAME    CHAR(20) OUTPUT
  )
AS  
  
/*  
 *     PROCEDURE NAME    : AKAX_RETRIEVE_S13  
 *     DESCRIPTION       : This procedure is used to retrieve first,last,middle name based on member_mci,type_alias,end validity. 
 *     DEVELOPED BY      : IMP TEAM  
 *     DEVELOPED ON      : 02-SEP-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
BEGIN  
      SELECT @Ac_LastAlias_NAME   = NULL,
             @Ac_FirstAlias_NAME  = NULL,
             @Ac_MiddleAlias_NAME = NULL;
      
      DECLARE  
         @Lc_AliasNameTypeT_CODE	CHAR(1)		= 'T',
         @Ld_High_DATE				DATE		= '12/31/9999';  
          
      SELECT @Ac_LastAlias_NAME		=	a.LastAlias_NAME,
			 @Ac_FirstAlias_NAME	=	a.FirstAlias_NAME,
			 @Ac_MiddleAlias_NAME	=	a.MiddleAlias_NAME
        FROM AKAX_Y1  a 
       WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO    
		 AND a.TypeAlias_CODE = @Lc_AliasNameTypeT_CODE    
		 AND a.TransactionEventSeq_NUMB =   
         (SELECT MAX(c.TransactionEventSeq_NUMB) 
            FROM AKAX_Y1 c  
           WHERE c.MemberMci_IDNO = a.MemberMci_IDNO    
             AND c.TypeAlias_CODE = @Lc_AliasNameTypeT_CODE    
             AND c.EndValidity_DATE = @Ld_High_DATE 
          )  
			 AND a.EndValidity_DATE = @Ld_High_DATE; 
END;--End of AKAX_RETRIEVE_S13  

GO
