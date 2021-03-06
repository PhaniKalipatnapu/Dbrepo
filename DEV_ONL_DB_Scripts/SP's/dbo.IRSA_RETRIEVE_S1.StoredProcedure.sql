/****** Object:  StoredProcedure [dbo].[IRSA_RETRIEVE_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IRSA_RETRIEVE_S1]  
(
     @An_MemberMci_IDNO		 NUMERIC(10,0),
     @Ac_PreEdit_CODE		 CHAR(2)	 OUTPUT
 )    
AS

/*
 *     PROCEDURE NAME    : IRSA_RETRIEVE_S1
 *     DESCRIPTION       : This procedure retrieves preedit_code according to member_mci.
 *     DEVELOPED BY      : IMP TEAM
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/BEGIN
     SET @Ac_PreEdit_CODE = NULL;
  SELECT TOP 1 @Ac_PreEdit_CODE = i.PreEdit_CODE
    FROM IRSA_Y1 i
   WHERE i.MemberMci_IDNO = @An_MemberMci_IDNO;
END;--End of IRSA_RETRIEVE_S1

GO
