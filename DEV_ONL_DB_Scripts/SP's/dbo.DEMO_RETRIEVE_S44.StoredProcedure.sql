/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S44]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S44] (
 @An_MemberMci_IDNO NUMERIC(10, 0),
 @Ac_Last_NAME      CHAR(20) OUTPUT,
 @Ac_First_NAME     CHAR(16) OUTPUT,
 @Ac_Middle_NAME    CHAR(20) OUTPUT,
 @Ac_Suffix_NAME    CHAR(4) OUTPUT,
 @Ac_MemberSex_CODE CHAR(1) OUTPUT,
 @An_MemberSsn_NUMB NUMERIC(9, 0) OUTPUT,
 @Ad_Birth_DATE     DATE OUTPUT
 )
AS
 /*                                              
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S44     
  *     DESCRIPTION       : Retrieving the Member details.                     
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 12-AUG-2011          
  *     MODIFIED BY       :                      
  *     MODIFIED ON       :                      
  *     VERSION NO        : 1                    
 */
 BEGIN
  SELECT @Ad_Birth_DATE = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_MemberSex_CODE = NULL,
         @An_MemberSsn_NUMB = NULL;

  SELECT @Ac_Last_NAME = D.Last_NAME,
         @Ac_First_NAME = D.First_NAME,
         @Ac_Middle_NAME = D.Middle_NAME,
         @Ac_Suffix_NAME = D.Suffix_NAME,
         @Ac_MemberSex_CODE = D.MemberSex_CODE,
         @An_MemberSsn_NUMB = D.MemberSsn_NUMB,
         @Ad_Birth_DATE = D.Birth_DATE
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; --END OF  DEMO_RETRIEVE_S44

GO
