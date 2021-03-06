/****** Object:  StoredProcedure [dbo].[OTHP_INSERT_S2]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OTHP_INSERT_S2] (
 @An_OtherParty_IDNO NUMERIC(9, 0) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : OTHP_INSERT_S2
  *     DESCRIPTION       : Generate Other Party number for IdentSeqOthp Table.
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 08-AUG-2011
  *     MODIFIED BY       : 
  *     MODIFIED ON       : 
  *     VERSION NO        : 1
 */
 BEGIN
  SET @An_OtherParty_IDNO = NULL;

  DECLARE @Ld_Systemdatetime_DTTM DATETIME2 = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();

  INSERT IOTHP_Y1
         (Entered_DATE)
  VALUES ( @Ld_Systemdatetime_DTTM );

  SET @An_OtherParty_IDNO = @@IDENTITY;
 END; -- END OF OTHP_INSERT_S2



GO
