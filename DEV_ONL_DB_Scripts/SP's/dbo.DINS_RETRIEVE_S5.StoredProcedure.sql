/****** Object:  StoredProcedure [dbo].[DINS_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DINS_RETRIEVE_S5] (
 @An_MemberMci_IDNO        NUMERIC(10, 0),
 @An_ChildMCI_IDNO         NUMERIC(10, 0),
 @An_OthpInsurance_IDNO    NUMERIC(9, 0),
 @Ac_InsuranceGroupNo_TEXT CHAR(25),
 @Ac_PolicyInsNo_TEXT      CHAR(20),
 @Ad_Begin_DATE            DATE,
 @Ad_End_DATE              DATE,
 @Ai_Count_QNTY            INT OUTPUT
 )
AS
 /*  
  *     PROCEDURE NAME    : DINS_RETRIEVE_S5  
  *     DESCRIPTION       : Retrieve the count of records from Dependant Insurance table for Unique number assigned by the system to the participant (This is the DCN of the NCP or the CP by whom the insurance is provided to the dependent), Dependent's ID for whom the insurance is provided, Unique number assigned by the system to the Insurance Co. of the Participant, Group number of the Participant Insurance and Policy Number of the Participant.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-OCT-2011  
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
  */
 BEGIN
  SET @Ai_Count_QNTY = NULL;

  DECLARE @Lc_Space_TEXT CHAR(1) = ' ',
          @Ld_High_DATE  DATE = '12/31/9999';

  SELECT @Ai_Count_QNTY = COUNT(1)
    FROM DINS_Y1 DI
   WHERE DI.MemberMci_IDNO = @An_MemberMci_IDNO
     AND DI.ChildMCI_IDNO = @An_ChildMCI_IDNO
     AND DI.OthpInsurance_IDNO = @An_OthpInsurance_IDNO
     AND ISNULL(DI.InsuranceGroupNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_InsuranceGroupNo_TEXT, @Lc_Space_TEXT)
     AND ISNULL(DI.PolicyInsNo_TEXT, @Lc_Space_TEXT) = ISNULL(@Ac_PolicyInsNo_TEXT, @Lc_Space_TEXT)
     AND DI.EndValidity_DATE = @Ld_High_DATE
     AND DI.Begin_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE)
     AND DI.End_DATE BETWEEN @Ad_Begin_DATE AND ISNULL(@Ad_End_DATE, @Ld_High_DATE);
 END -- End of DINS_RETRIEVE_S5

GO
