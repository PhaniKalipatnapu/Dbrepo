/****** Object:  StoredProcedure [dbo].[PLIC_RETRIEVE_S9]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PLIC_RETRIEVE_S9] (
 @An_MemberMci_IDNO   NUMERIC(10, 0),
 @Ac_TypeLicense_CODE CHAR(5),
 @Ac_Status_CODE      CHAR(2),
 @Ai_Count_QNTY       INT OUTPUT
 )
AS
 /*      
  *     PROCEDURE NAME    : PLIC_RETRIEVE_S9      
  *     DESCRIPTION       : Retrieve record count for a Member Idno, License Type Code, Issuing State Code and Status Code.      
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 15-SEP-2011      
  *     MODIFIED BY       :       
  *     MODIFIED ON       :       
  *     VERSION NO        : 1      
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Ld_High_DATE DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM PLIC_Y1 a
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND RTRIM(LTRIM(a.TypeLicense_CODE)) = @Ac_TypeLicense_CODE
     AND a.Status_CODE = @Ac_Status_CODE
     AND a.EndValidity_DATE = @Ld_High_DATE;
 END; --End Of PLIC_RETRIEVE_S9    

GO
