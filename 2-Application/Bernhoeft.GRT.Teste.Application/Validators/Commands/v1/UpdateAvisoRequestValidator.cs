using Bernhoeft.GRT.Teste.Application.Requests.Commands.v1;
using FluentValidation;

namespace Bernhoeft.GRT.Teste.Application.Validators.Commands.v1
{
    public class UpdateAvisoRequestValidator : AbstractValidator<UpdateAvisoRequest>
    {
        public UpdateAvisoRequestValidator()
        {
            RuleFor(x => x.Id)
                .GreaterThan(0)
                .WithMessage("O ID deve ser maior que zero.");

            RuleFor(x => x.Mensagem)
                .NotNull()
                .WithMessage("A mensagem é obrigatória.")
                .NotEmpty()
                .WithMessage("A mensagem não pode ser vazia.");
        }
    }
}