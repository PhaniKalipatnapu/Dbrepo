/****** Object:  StoredProcedure [dbo].[VAPP_RETRIEVE_S10]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[VAPP_RETRIEVE_S10] (
 @An_ChildMemberMci_IDNO   NUMERIC(10, 0),
 @Ac_DataRecordStatus_CODE CHAR(1),
 @Ac_Exists_INDC           CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : VAPP_RETRIEVE_S10
  *     DESCRIPTION       : Check the Record is exist for the given data record status code,child member.  
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 02-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
  */
 BEGIN
  DECLARE @Lc_No_TEXT           CHAR(1) = 'N',
          @Lc_Yes_TEXT          CHAR(1) = 'Y',
          @Lc_TypeDocument_CODE CHAR(3) = 'VAP';

  SET @Ac_Exists_INDC = @Lc_No_TEXT;

  SELECT @Ac_Exists_INDC = @Lc_Yes_TEXT
    FROM VAPP_Y1 V
   WHERE V.ChildMemberMci_IDNO = @An_ChildMemberMci_IDNO
     AND V.TypeDocument_CODE = @Lc_TypeDocument_CODE
     AND V.DataRecordStatus_CODE = @Ac_DataRecordStatus_CODE
	 AND V.ImageLink_INDC= @Lc_Yes_TEXT ;

 END; --End of VAPP_RETRIEVE_S10

GO
