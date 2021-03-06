/****** Object:  StoredProcedure [dbo].[APMH_RETRIEVE_S34]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[APMH_RETRIEVE_S34] (  
@An_CaseWelfare_IDNO NUMERIC( 10,0),
@Ac_Exists_INDC CHAR(1) OUTPUT

 )  
AS  
 /*  
  *     PROCEDURE NAME    : APMH_RETRIEVE_S34  
  *     DESCRIPTION       : Checks whether the casewelfareidno exists or not  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 4/26/2012
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
 
 DECLARE @Ld_High_DATE DATE = '12/31/9999',
        @Lc_TypeWelfareFostercare_CODE CHAR(1) = 'F',
        @Lc_Yes_INDC CHAR(1)  ='Y';
        
SET @Ac_Exists_INDC = NULL;

SELECT @Ac_Exists_INDC = @Lc_Yes_INDC
	FROM 
	APCS_Y1 AC INNER JOIN 
	APMH_Y1 AP  
ON
AC.Application_IDNO = AP.Application_IDNO 
WHERE
AC.CaseWelfare_IDNO = @An_CaseWelfare_IDNO
AND 
	AC.TYPEWELFARE_CODE = @Lc_TypeWelfareFostercare_CODE
 AND AC.EndValidity_DATE = @Ld_High_DATE
 AND AP.EndValidity_DATE = @Ld_High_DATE;
 
END
 
GO
