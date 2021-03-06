/****** Object:  StoredProcedure [dbo].[OTHP_RETRIEVE_S70]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_RETRIEVE_S70](
 @An_MemberMci_IDNO NUMERIC(10, 0)
 )
AS
 /*  
  *     PROCEDURE NAME    : OTHP_RETRIEVE_S70  
  *     DESCRIPTION       : Retrieve Unique System Assigned number for the Other Party and Other Party Name Code by deriving it from Unique System Assigned number for the Other Party and Name of the Other Party for Unique number assigned by the system to the participant whose Date on which the Participant terminated the employment with the Employer equal to High Date (31-DEC-9999) and Unique number assigned by the system to the employer exists in Other Party table with Other Party Type equal to Employer (E) / Union (U) / Military (M) and End Validity Date equal to High Date (31-DEC-9999).
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 12-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  DECLARE @Ld_High_DATE             DATE = '12/31/9999',
          @Lc_TypeOthpEmployer_CODE CHAR(1) = 'E',
          @Lc_TypeOthpMilitary_CODE CHAR(1) = 'M',
          @Lc_TypeOthpUnion_CODE    CHAR(1) = 'U';

  SELECT b.OtherParty_IDNO,
         b.OtherParty_NAME
    FROM EHIS_Y1 a
         JOIN OTHP_Y1 b
          ON a.OthpPartyEmpl_IDNO = b.OtherParty_IDNO
   WHERE a.MemberMci_IDNO = @An_MemberMci_IDNO
     AND b.TypeOthp_CODE IN (@Lc_TypeOthpEmployer_CODE, @Lc_TypeOthpUnion_CODE, @Lc_TypeOthpMilitary_CODE)
     AND b.EndValidity_DATE = @Ld_High_DATE
     AND a.EndEmployment_DATE = @Ld_High_DATE;
 END -- End of OTHP_RETRIEVE_S70

GO
