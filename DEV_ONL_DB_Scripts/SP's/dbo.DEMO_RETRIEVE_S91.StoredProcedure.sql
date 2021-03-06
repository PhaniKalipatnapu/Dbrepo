/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S91]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S91] (
 @An_MemberMci_IDNO		 	NUMERIC(10,0),
 @Ac_Last_NAME		 		CHAR(20)	  OUTPUT,
 @Ac_First_NAME		 		CHAR(16)	  OUTPUT,
 @Ac_Middle_NAME		 	CHAR(20)	  OUTPUT,
 @Ac_Suffix_NAME		 	CHAR(4)		  OUTPUT,
 @Ac_MemberSex_CODE		 	CHAR(1)	 	  OUTPUT,
 @An_MemberSsn_NUMB		 	NUMERIC(9,0)  OUTPUT,
 @Ad_Birth_DATE				DATE	 	  OUTPUT,       
 @An_WelfareMemberMci_IDNO	NUMERIC(10,0) OUTPUT
 )
AS

/*
 *     PROCEDURE NAME    : DEMO_RETRIEVE_S91
 *     DESCRIPTION       : Retrieve Member Information such as last name of the Member, first name of the Member, middle initial of the Member, Suffix of the Member, Members date of birth, Gender of the Member and Members social security number from Member Demographics table for Unique number assigned by the system to the participant and retrieve Welfare Identification of the Member from Member Welfare Details table for Unique number assigned by the system to the participant whose Welfare Identification of the Member exists in Member Demographics table. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 19-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */

   BEGIN

      SELECT @Ac_MemberSex_CODE = NULL,
	         @Ad_Birth_DATE = NULL,
		     @An_WelfareMemberMci_IDNO = NULL,
	         @An_MemberSsn_NUMB = NULL,
	         @Ac_First_NAME = NULL,
		     @Ac_Last_NAME = NULL,
             @Ac_Middle_NAME = NULL,
	         @Ac_Suffix_NAME = NULL;

  SELECT @Ac_Last_NAME = a.Last_NAME, 
         @Ac_First_NAME = a.First_NAME, 
         @Ac_Middle_NAME = a.Middle_NAME, 
         @Ac_Suffix_NAME = a.Suffix_NAME, 
         @Ac_MemberSex_CODE = a.MemberSex_CODE, 
         @An_MemberSsn_NUMB = a.MemberSsn_NUMB, 
         @Ad_Birth_DATE = a.Birth_DATE, 
         @An_WelfareMemberMci_IDNO = ( SELECT DISTINCT TOP 1 b.WelfareMemberMci_IDNO
            						     FROM MHIS_Y1  b
            						    WHERE b.MemberMci_IDNO = @An_MemberMci_IDNO 
            						      AND b.WelfareMemberMci_IDNO IS NOT NULL )
   FROM DEMO_Y1 a
  WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO;

END; --END OF DEMO_RETRIEVE_S91


GO
